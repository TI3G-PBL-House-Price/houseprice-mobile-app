import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../failures.dart';
import '../session/auth_session.dart';
import 'api_constants.dart';

/// Client HTTP terpusat untuk komunikasi dengan backend Flask HousePrice.
class ApiClient {
  ApiClient._();

  static http.Client _client = http.Client();

  /// Setter client untuk keperluan mock testing.
  static set client(http.Client customClient) {
    _client = customClient;
  }

  /// Headers standar untuk setiap request.
  static Map<String, String> _buildHeaders({Map<String, String>? extraHeaders, bool requireAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth && AuthSession.token != null && AuthSession.token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${AuthSession.token}';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  /// Request GET dengan autentikasi opsional & timeout guard.
  static Future<dynamic> get(
    String url, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: _buildHeaders(extraHeaders: headers, requireAuth: requireAuth),
          )
          .timeout(ApiConstants.timeoutDuration);

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkFailure('Gagal terhubung ke server backend: ${e.message}');
    } on TimeoutException {
      throw const NetworkFailure('Koneksi ke backend server waktu habis (timeout)');
    } on http.ClientException catch (e) {
      throw NetworkFailure('Kesalahan koneksi HTTP: ${e.message}');
    }
  }

  /// Request POST dengan payload JSON & timeout guard.
  static Future<dynamic> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _buildHeaders(extraHeaders: headers, requireAuth: requireAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.timeoutDuration);

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkFailure('Gagal terhubung ke server backend: ${e.message}');
    } on TimeoutException {
      throw const NetworkFailure('Koneksi ke backend server waktu habis (timeout)');
    } on http.ClientException catch (e) {
      throw NetworkFailure('Kesalahan koneksi HTTP: ${e.message}');
    }
  }

  /// Pemrosesan respon status HTTP dan penanganan error standar REST API Flask.
  static dynamic _handleResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    final message = (decoded is Map && decoded['message'] != null)
        ? decoded['message'].toString()
        : 'Status respon HTTP: ${response.statusCode}';

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else if (response.statusCode == 400) {
      final details = (decoded is Map && decoded['details'] is List)
          ? (decoded['details'] as List).join(', ')
          : message;
      throw ValidationFailure(details);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw AuthFailure(message);
    } else if (response.statusCode == 409) {
      throw ValidationFailure(message);
    } else {
      throw ServerFailure(message);
    }
  }
}
