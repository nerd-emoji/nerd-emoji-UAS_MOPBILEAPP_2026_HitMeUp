import 'package:flutter_test/flutter_test.dart';

void main() {

  group('community_details unit test', () {

    test('string validation', () {
      String name = 'Community';
      expect(name.isNotEmpty, true);
    });

    test('max participants valid number', () {
      String input = '10';
      final parsed = int.tryParse(input);

      expect(parsed != null && parsed > 0, true);
    });

    test('invalid number returns null', () {
      String input = 'abc';
      final parsed = int.tryParse(input);

      expect(parsed, null);
    });

  });

}