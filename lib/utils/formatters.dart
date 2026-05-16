import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ==================== FORMAT CURRENCY ====================
String formatRupiah(double amount) {
  final isNegative = amount < 0;
  final absAmount = amount.abs();
  final formatted = NumberFormat('#,##0', 'id_ID').format(absAmount);
  if (isNegative) return '($formatted)';
  return formatted;
}

double parseRupiah(String text) {
  final clean = text.replaceAll(RegExp(r'[^\d]'), '');
  return double.tryParse(clean) ?? 0.0;
}

String formatRupiahDenganPrefix(double amount) {
  final isNegative = amount < 0;
  final absAmount = amount.abs();
  final formatted = NumberFormat('#,##0', 'id_ID').format(absAmount);
  if (isNegative) return 'Rp ($formatted)';
  return 'Rp $formatted';
}

String formatRupiahCompact(double amount) {
  if (amount.abs() >= 1000000) {
    return NumberFormat.compact(locale: 'id_ID').format(amount);
  }
  return formatRupiah(amount);
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');

    int value = int.parse(cleanText);
    String formatted = NumberFormat.decimalPattern('id_ID').format(value);

    int cursorPosition = formatted.length;
    if (newValue.selection.isValid) {
      int rightOffset = newValue.text.length - newValue.selection.end;
      cursorPosition = formatted.length - rightOffset;
      if (cursorPosition < 0) cursorPosition = 0;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

String formatCurrency(double amount, String currencyCode) {
  final formats = {
    'IDR': NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ),
    'USD': NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    ),
    'EUR': NumberFormat.currency(
      locale: 'de_DE',
      symbol: '\u20ac',
      decimalDigits: 2,
    ),
    'SGD': NumberFormat.currency(
      locale: 'en_SG',
      symbol: 'S\$',
      decimalDigits: 2,
    ),
    'JPY': NumberFormat.currency(
      locale: 'ja_JP',
      symbol: '\u00a5',
      decimalDigits: 0,
    ),
    'MYR': NumberFormat.currency(
      locale: 'ms_MY',
      symbol: 'RM',
      decimalDigits: 2,
    ),
  };
  return formats[currencyCode]?.format(amount) ??
      formats['IDR']!.format(amount);
}

String getCurrencySymbol(String currencyCode) {
  final symbols = {
    'IDR': 'Rp ',
    'USD': '\$',
    'EUR': '\u20ac',
    'SGD': 'S\$',
    'JPY': '\u00a5',
    'MYR': 'RM',
  };
  return symbols[currencyCode] ?? 'Rp ';
}

String getCurrencyName(String currencyCode) {
  final names = {
    'IDR': 'Rupiah Indonesia',
    'USD': 'Dolar Amerika',
    'EUR': 'Euro',
    'SGD': 'Dolar Singapura',
    'JPY': 'Yen Jepang',
    'MYR': 'Ringgit Malaysia',
  };
  return names[currencyCode] ?? currencyCode;
}
