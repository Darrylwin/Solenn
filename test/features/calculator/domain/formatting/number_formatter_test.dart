import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/calculator/domain/formatting/number_formatter.dart';
import 'package:solenn/features/calculator/domain/formatting/number_symbols.dart';

const NumberFormatter _english = NumberFormatter(NumberSymbols.english);

const NumberFormatter _french = NumberFormatter(
  NumberSymbols(decimalSeparator: ',', groupSeparator: '\u202F'),
);

const NumberFormatter _german = NumberFormatter(
  NumberSymbols(decimalSeparator: ',', groupSeparator: '.'),
);

void _expectValues(NumberFormatter formatter, Map<String, String> cases) {
  cases.forEach((canonical, expected) {
    test('$canonical should read $expected', () {
      expect(formatter.formatValue(canonical), expected);
    });
  });
}

void main() {
  group('formatValue in positional notation', () {
    _expectValues(_english, {
      '0': '0',
      '5': '5',
      '-5': '-5',
      '12': '12',
      '123': '123',
      '1234': '1,234',
      '24820': '24,820',
      '123456': '123,456',
      '1234567': '1,234,567',
      '123456789': '123,456,789',
      '999999999': '999,999,999',
      '-1234.56': '-1,234.56',
      '0.5': '0.5',
      '1234.5': '1,234.5',
      '0.25': '0.25',
      '0.000001': '0.000001',
      '0.0000012345': '0.0000012345',
    });

    _expectValues(_english, {
      '0.333333333333333': '0.333333333',
      '0.666666666666667': '0.666666667',
      '3.14285714285714': '3.14285714',
      '33.3333333333333': '33.3333333',
      '123456789.5': '123,456,790',
      '12345678.95': '12,345,679',
      '-0.666666666666667': '-0.666666667',
    });
  });

  group('formatValue in scientific notation', () {
    _expectValues(_english, {
      '1000000000': '1e+9',
      '999999999.5': '1e+9',
      '1234567890': '1.23456789e+9',
      '-1234567890': '-1.23456789e+9',
      '123456789012345': '1.23456789e+14',
      '15241578750190500': '1.52415788e+16',
      '0.0000001': '1e-7',
      '-0.0000001': '-1e-7',
      '0.00000012345': '1.2345e-7',
      '0.000000001000000001': '1e-9',
    });

    test('should reach the ends of the range', () {
      expect(_english.formatValue('1${'0' * 99}'), '1e+99');
      expect(_english.formatValue('0.${'0' * 98}1'), '1e-99');
    });
  });

  group('formatValue with a percent sign', () {
    test('should append it', () {
      expect(_english.formatValue('50', isPercent: true), '50%');
      expect(_english.formatValue('0.5', isPercent: true), '0.5%');
    });

    test('should leave a plain number untouched', () {
      expect(_english.formatValue('50'), '50');
    });
  });

  group('formatValue with other locales', () {
    _expectValues(_french, {
      '1234567.89': '1\u202F234\u202F567,89',
      '1234': '1\u202F234',
      '0.5': '0,5',
    });

    _expectValues(_german, {
      '1234567.89': '1.234.567,89',
      '1234567890': '1,23456789e+9',
      '0.0000001': '1e-7',
    });

    test('should skip grouping when the locale has no group separator', () {
      const formatter = NumberFormatter(
        NumberSymbols(decimalSeparator: '.', groupSeparator: ''),
      );

      expect(formatter.formatValue('1234567'), '1234567');
    });

    test('should use the minus sign of the locale', () {
      const formatter = NumberFormatter(
        NumberSymbols(
          decimalSeparator: '.',
          groupSeparator: ',',
          minusSign: '\u2212',
        ),
      );

      expect(formatter.formatValue('-5'), '\u22125');
      expect(formatter.formatValue('-1234567890'), '\u22121.23456789e+9');
      expect(formatter.formatValue('0.0000001'), '1e\u22127');
    });
  });

  group('formatEntry', () {
    void expectEntries(NumberFormatter formatter, Map<String, String> cases) {
      cases.forEach((entry, expected) {
        test('$entry should read $expected', () {
          expect(formatter.formatEntry(entry), expected);
        });
      });
    }

    expectEntries(_english, {
      '0': '0',
      '5': '5',
      '12345': '12,345',
      '123456789': '123,456,789',
      '-0': '-0',
      '-5': '-5',
      '0.': '0.',
      '5.': '5.',
      '1.50': '1.50',
      '1234.500': '1,234.500',
      '-1234.5': '-1,234.5',
      '12345678.9': '12,345,678.9',
    });

    expectEntries(_french, {
      '1234.5': '1\u202F234,5',
      '5.': '5,',
    });

    test('should append the percent sign', () {
      expect(_english.formatEntry('5', isPercent: true), '5%');
      expect(_english.formatEntry('-1234', isPercent: true), '-1,234%');
    });
  });

  test('should show nine significant digits', () {
    expect(displayDigits, 9);
  });

  test('should compare symbols by value', () {
    expect(
      NumberSymbols.english,
      NumberSymbols.english,
    );
    expect(
      NumberSymbols.english,
      isNot(const NumberSymbols(decimalSeparator: ',', groupSeparator: '.')),
    );
  });
}
