import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:houseprice_mobile_app/core/network/api_client.dart';
import 'package:houseprice_mobile_app/core/network/api_constants.dart';
import 'package:houseprice_mobile_app/core/session/auth_session.dart';
import 'package:houseprice_mobile_app/features/home/data/market_service.dart';
import 'package:houseprice_mobile_app/features/prediction/data/prediction_result_data.dart';
import 'package:houseprice_mobile_app/features/prediction/data/prediction_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Backend Flask & ML v2 Integration Tests', () {
    test('ApiConstants configuration URLs are properly formed', () {
      expect(ApiConstants.loginUrl, contains('/api/v1/auth/login'));
      expect(ApiConstants.registerUrl, contains('/api/v1/auth/register'));
      expect(ApiConstants.predictUrl, contains('/api/v1/predict'));
      expect(ApiConstants.locationsUrl, contains('/api/v1/locations'));
      expect(ApiConstants.marketStatsUrl, contains('/api/v1/market-statistics'));
    });

    test('PredictionResultData maps Flask API response correctly', () {
      final mockApiResponse = {
        'status': 'success',
        'message': 'Estimasi harga properti berhasil dihitung',
        'data': {
          'prediction_id': 'f7d23a9b-8e12-4c28-98e3-abc123456789',
          'predicted_price': 3250000000.0,
          'currency': 'IDR',
          'tolerance_range': {
            'lower_bound': 2925000000.0,
            'upper_bound': 3575000000.0,
          },
          'model_info': {
            'version': 'v2.0.0',
            'algorithm': 'XGBoost Regressor (Tuned)',
          },
          'performance': {
            'latency_ms': 128,
          },
        },
      };

      final result = PredictionResultData.fromApiResponse(
        data: mockApiResponse['data'] as Map<String, dynamic>,
        city: 'Jakarta Selatan',
        district: 'Kebayoran Baru',
        landArea: 150,
        buildingArea: 130,
        bedrooms: 4,
        bathrooms: 3,
        garage: 2,
      );

      expect(result.city, 'Jakarta Selatan');
      expect(result.district, 'Kebayoran Baru');
      expect(result.landArea, 150);
      expect(result.buildingArea, 130);
      expect(result.bedrooms, 4);
      expect(result.bathrooms, 3);
      expect(result.garage, 2);
      expect(result.predictedPrice, 3250000000.0);
      expect(result.midPrice, 3250000000);
      expect(result.lowerBound, 2925000000);
      expect(result.upperBound, 3575000000);
      expect(result.modelVersion, 'v2.0.0');
      expect(result.algorithm, 'XGBoost Regressor (Tuned)');
      expect(result.latencyMs, 128);
      expect(result.predictionId, 'f7d23a9b-8e12-4c28-98e3-abc123456789');
    });

    test('PredictionService.predictPrice sends correct payload to Flask API', () async {
      ApiClient.client = MockClient((request) async {
        expect(request.url.toString(), contains('/api/v1/predict'));
        expect(request.method, 'POST');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['city'], 'Jakarta Selatan');
        expect(body['district'], 'Kebayoran Baru');
        expect(body['surface_area'], 140.0);
        expect(body['building_area'], 120.0);
        expect(body['bed'], 3);
        expect(body['bath'], 2);
        expect(body['carport'], 1);

        return http.Response(
          jsonEncode({
            'status': 'success',
            'message': 'Estimasi harga properti berhasil dihitung',
            'data': {
              'prediction_id': 'test-uuid-1234',
              'predicted_price': 2650000000.0,
              'currency': 'IDR',
              'tolerance_range': {
                'lower_bound': 2385000000.0,
                'upper_bound': 2915000000.0,
              },
              'model_info': {
                'version': 'v2.0.0',
                'algorithm': 'XGBoost Regressor (Tuned)',
              },
              'performance': {
                'latency_ms': 118,
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final result = await PredictionService.predictPrice(
        city: 'Jakarta Selatan',
        district: 'Kebayoran Baru',
        surfaceArea: 140.0,
        buildingArea: 120.0,
        bed: 3,
        bath: 2,
        carport: 1,
      );

      expect(result.predictedPrice, 2650000000.0);
      expect(result.lowerBound, 2385000000);
      expect(result.upperBound, 2915000000);
      expect(result.modelVersion, 'v2.0.0');
    });

    test('PredictionService.offlineFallback provides valid estimation when offline', () {
      final fallback = PredictionService.offlineFallback(
        city: 'Jakarta Selatan',
        district: 'Kebayoran Baru',
        surfaceArea: 140.0,
        buildingArea: 120.0,
        bed: 3,
        bath: 2,
        carport: 1,
      );

      expect(fallback.city, 'Jakarta Selatan');
      expect(fallback.lowerBound, greaterThan(0));
      expect(fallback.upperBound, greaterThan(fallback.lowerBound));
      expect(fallback.predictedPrice, greaterThan(0));
      expect(fallback.modelVersion, contains('Offline Mode'));
    });

    test('MarketService.fetchLocations parses Flask API master locations', () async {
      ApiClient.client = MockClient((request) async {
        expect(request.url.toString(), contains('/api/v1/locations'));
        return http.Response(
          jsonEncode({
            'status': 'success',
            'message': 'Master lokasi berhasil dimuat',
            'data': [
              {
                'city': 'Jakarta Selatan',
                'districts': ['Kebayoran Baru', 'Cilandak', 'Pancoran'],
                'njop_per_m2': {'Kebayoran Baru': 13363000.0},
              },
              {
                'city': 'Jakarta Barat',
                'districts': ['Kebon Jeruk', 'Cengkareng'],
                'njop_per_m2': {'Kebon Jeruk': 6195000.0},
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final res = await MarketService.fetchLocations();
      final cities = res['cities'] as List<String>;
      final districtMap = res['districtMap'] as Map<String, List<String>>;

      expect(cities, contains('Jakarta Selatan'));
      expect(cities, contains('Jakarta Barat'));
      expect(districtMap['Jakarta Selatan'], contains('Kebayoran Baru'));
    });

    test('AuthSession.loginWithBackend parses JWT token and sets active session', () async {
      ApiClient.client = MockClient((request) async {
        expect(request.url.toString(), contains('/api/v1/auth/login'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'budi.santoso@gmail.com');
        expect(body['password'], 'Password123!');

        return http.Response(
          jsonEncode({
            'status': 'success',
            'message': 'Login berhasil',
            'data': {
              'access_token': 'test_jwt_bearer_token_abc123',
              'token_type': 'Bearer',
              'expires_in': 604800,
              'user': {
                'id': 'user-uuid-1',
                'full_name': 'Budi Santoso',
                'email': 'budi.santoso@gmail.com',
                'phone_number': '081234567890',
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final error = await AuthSession.loginWithBackend(
        'budi.santoso@gmail.com',
        'Password123!',
      );

      expect(error, isNull);
      expect(AuthSession.isLoggedIn, isTrue);
      expect(AuthSession.token, 'test_jwt_bearer_token_abc123');
      expect(AuthSession.currentUserEmail, 'budi.santoso@gmail.com');
      expect(AuthSession.currentUserName, 'Budi Santoso');
    });
  });
}
