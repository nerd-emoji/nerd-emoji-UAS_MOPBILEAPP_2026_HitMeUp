import 'package:flutter_test/flutter_test.dart';

void main() {

  group('community_chat unit test', () {

    test('string not empty', () {
      String msg = 'community chat';
      expect(msg.isNotEmpty, true);
    });

    test('list add works', () {
      List<int> list = [];
      list.add(1);

      expect(list.length, 1);
    });

    test('datetime format basic', () {
      final now = DateTime.now().toIso8601String();
      expect(now.contains('T'), true);
    });

  });

}