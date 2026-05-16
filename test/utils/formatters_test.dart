import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_keuangan/utils/formatters.dart';

void main() {
  group('formatters.dart Tests', () {
    group('formatRupiah', () {
      test('formats positive numbers correctly', () {
        expect(formatRupiah(1000000), equals('1.000.000'));
        expect(formatRupiah(500000), equals('500.000'));
        expect(formatRupiah(999999), equals('999.999'));
      });

      test('formats zero correctly', () {
        expect(formatRupiah(0), equals('0'));
      });

      test('formats negative numbers with parentheses', () {
        expect(formatRupiah(-100000), equals('(100.000)'));
        expect(formatRupiah(-500), equals('(500)'));
      });

      test('formats decimal values correctly', () {
        expect(formatRupiah(1000.50), equals('1.000'));
        expect(formatRupiah(1234.99), equals('1.234'));
      });

      test('handles large numbers', () {
        expect(formatRupiah(1000000000), equals('1.000.000.000'));
        expect(formatRupiah(9999999999), equals('9.999.999.999'));
      });
    });

    group('parseRupiah', () {
      test('parses formatted string to number', () {
        expect(parseRupiah('1.000.000'), equals(1000000.0));
        expect(parseRupiah('500.000'), equals(500000.0));
      });

      test('parses string with Rp prefix', () {
        expect(parseRupiah('Rp 1.000.000'), equals(1000000.0));
        expect(parseRupiah('Rp500.000'), equals(500000.0));
      });

      test('returns zero for invalid input', () {
        expect(parseRupiah(''), equals(0.0));
        expect(parseRupiah('abc'), equals(0.0));
      });

      test('handles negative values', () {
        expect(parseRupiah('-100.000'), equals(100000.0));
      });
    });

    group('formatRupiahDenganPrefix', () {
      test('adds Rp prefix to positive numbers', () {
        expect(formatRupiahDenganPrefix(1000000), equals('Rp 1.000.000'));
      });

      test('formats negative numbers with parentheses', () {
        expect(formatRupiahDenganPrefix(-500000), equals('Rp (500.000)'));
      });
    });

    group('formatRupiahCompact', () {
      test('formats millions compact', () {
        expect(formatRupiahCompact(1000000), equals('1,0 jt'));
        expect(formatRupiahCompact(5000000), equals('5,0 jt'));
      });

      test('formats regular numbers without compact', () {
        expect(formatRupiahCompact(500000), equals('500.000'));
        expect(formatRupiahCompact(999999), equals('999.999'));
      });

      test('formats negative numbers compact', () {
        final result = formatRupiahCompact(-1000000);
        expect(result.contains('-'), isTrue);
      });

      test('formats thousands correctly', () {
        expect(formatRupiahCompact(50000), equals('50.000'));
        expect(formatRupiahCompact(100000), equals('100.000'));
      });
    });

    group('CurrencyInputFormatter', () {
      test('formats input correctly', () {
        final formatter = CurrencyInputFormatter();

        // Empty input
        var result = formatter.formatEditUpdate(
          const TextEditingValue(text: ''),
          const TextEditingValue(text: ''),
        );
        expect(result.text, equals(''));

        // Single digit
        result = formatter.formatEditUpdate(
          const TextEditingValue(text: ''),
          const TextEditingValue(text: '1'),
        );
        expect(result.text, equals('1'));

        // Multiple digits with thousands separator
        result = formatter.formatEditUpdate(
          const TextEditingValue(text: '1'),
          const TextEditingValue(text: '1000'),
        );
        expect(result.text, equals('1.000'));
      });

      test('handles cursor position', () {
        final formatter = CurrencyInputFormatter();

        final result = formatter.formatEditUpdate(
          const TextEditingValue(text: '1000'),
          const TextEditingValue(text: '1000000'),
        );
        expect(result.selection.isValid, isTrue);
      });

      test('clears formatting on empty input', () {
        final formatter = CurrencyInputFormatter();

        final result = formatter.formatEditUpdate(
          const TextEditingValue(text: '1.000'),
          const TextEditingValue(text: ''),
        );
        expect(result.text, equals(''));
      });
    });

    group('formatCurrency', () {
      test('formats IDR correctly', () {
        final result = formatCurrency(1000000, 'IDR');
        expect(result, contains('1'));
        expect(result, contains('.'));
      });

      test('formats USD correctly', () {
        final result = formatCurrency(100.50, 'USD');
        expect(result, contains('100.50'));
        expect(result, contains('\$'));
      });

      test('formats EUR correctly', () {
        final result = formatCurrency(100.50, 'EUR');
        expect(result, contains('100'));
      });

      test('formats SGD correctly', () {
        final result = formatCurrency(100.50, 'SGD');
        expect(result, contains('S\$'));
      });

      test('formats JPY correctly (no decimals)', () {
        final result = formatCurrency(1000.50, 'JPY');
        expect(result, contains('1'));
      });

      test('formats MYR correctly', () {
        final result = formatCurrency(100.50, 'MYR');
        expect(result, contains('RM'));
      });

      test('falls back to IDR for unknown currency', () {
        final result = formatCurrency(1000, 'XXX');
        expect(result, contains('1'));
      });
    });

    group('getCurrencySymbol', () {
      test('returns correct symbols', () {
        expect(getCurrencySymbol('IDR'), equals('Rp '));
        expect(getCurrencySymbol('USD'), equals('\$'));
        expect(getCurrencySymbol('EUR'), equals('€'));
        expect(getCurrencySymbol('SGD'), equals('S\$'));
        expect(getCurrencySymbol('JPY'), equals('¥'));
        expect(getCurrencySymbol('MYR'), equals('RM'));
      });

      test('falls back to Rp for unknown currency', () {
        expect(getCurrencySymbol('XXX'), equals('Rp '));
      });
    });

    group('getCurrencyName', () {
      test('returns correct names', () {
        expect(getCurrencyName('IDR'), equals('Rupiah Indonesia'));
        expect(getCurrencyName('USD'), equals('Dolar Amerika'));
        expect(getCurrencyName('EUR'), equals('Euro'));
        expect(getCurrencyName('SGD'), equals('Dolar Singapura'));
        expect(getCurrencyName('JPY'), equals('Yen Jepang'));
        expect(getCurrencyName('MYR'), equals('Ringgit Malaysia'));
      });

      test('returns currency code for unknown', () {
        expect(getCurrencyName('XXX'), equals('XXX'));
      });
    });
  });
}