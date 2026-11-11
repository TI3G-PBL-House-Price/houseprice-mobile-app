import 'package:flutter/services.dart';

/// Formatter mata uang Rupiah untuk tampilan & input.
/// Dipakai di fitur KPR (kpr_form_page, kpr_result_page) dan
/// fitur Cek Kewajaran (result_page).
class CurrencyFormatter {
  static String formatRupiah(double amount, {bool showDecimal = false}) {
    String result = '';
    String amountStr;

    if (showDecimal) {
      amountStr = amount.toStringAsFixed(2);
    } else {
      amountStr = amount.toInt().toString();
    }

    bool isNegative = amountStr.startsWith('-');
    if (isNegative) {
      amountStr = amountStr.substring(1);
    }

    String intPart;
    String decPart = '';

    if (amountStr.contains('.')) {
      intPart = amountStr.split('.')[0];
      decPart = '.${amountStr.split('.')[1]}';
    } else {
      intPart = amountStr;
    }

    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      count++;
      result = intPart[i] + result;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }

    return '${isNegative ? '-' : ''}Rp $result$decPart';
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)} M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Juta';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} Ribu';
    }
    return 'Rp ${amount.toInt()}';
  }
}

/// Input formatter yang otomatis menambahkan titik pemisah ribuan.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (newText.isEmpty) {
      return const TextEditingValue(text: '');
    }

    String result = '';
    int count = 0;
    for (int i = newText.length - 1; i >= 0; i--) {
      count++;
      result = newText[i] + result;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

