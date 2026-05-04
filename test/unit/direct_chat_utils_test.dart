import 'package:flutter_test/flutter_test.dart';

void main() {

  group('direct_chat unit test', () {

    test('message should not be empty', () {
      String message = 'hello';
      expect(message.isNotEmpty, true);
    });

    test('timestamp format basic', () {
      final now = DateTime.now().toIso8601String();
      expect(now.contains('T'), true);
    });

    test('list message add works', () {
      List<String> messages = [];
      messages.add('Hi');

      expect(messages.length, 1);
    });

  });

}