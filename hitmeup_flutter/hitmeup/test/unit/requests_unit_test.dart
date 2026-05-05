import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/utils/requests_utils.dart';

void main() {

  group('Requests Utils Test', () {

    // ---------------------------
    // AGE TEST
    // ---------------------------
    test('calculate age correctly', () {
      final age = RequestsUtils.calculateAgeFromBirthday('2000-01-01');

      expect(age, greaterThan(20));
    });

    test('return 0 if birthday null', () {
      final age = RequestsUtils.calculateAgeFromBirthday(null);

      expect(age, 0);
    });

    test('return 0 if invalid date', () {

      final age = RequestsUtils.calculateAgeFromBirthday('invalid-date');

      expect(age, 0);
    });

    // ---------------------------
    // URL TEST
    // ---------------------------
    test('resolve absolute url', () {
      final url = RequestsUtils.resolveProfilePictureUrl(
        'https://example.com/image.jpg',
      );

      expect(url, 'https://example.com/image.jpg');
    });

    test('resolve relative url', () {
      final url = RequestsUtils.resolveProfilePictureUrl('profile.jpg');

      expect(url, isNotNull);
      expect(url!.contains('/media/'), true);
    });

    test('return null if empty url', () {
      final url = RequestsUtils.resolveProfilePictureUrl('');

      expect(url, null);
    });

    // ---------------------------
    // MAP TEST
    // ---------------------------
    test('map request to card correctly', () {
      final result = RequestsUtils.mapRequestToCard(
        requestId: 1,
        requesterId: 10,
        requesterData: {
          'name': 'John',
          'birthday': '2000-01-01',
          'level': 3,
          'diamonds': 50,
          'profilepicture': 'profile.jpg',
        },
      );

      expect(result.name, 'John');
      expect(result.level, 3);
      expect(result.diamonds, 50);
      expect(result.age, greaterThan(20));
    });

    test('map handles missing name', () {
      final result = RequestsUtils.mapRequestToCard(
        requestId: 1,
        requesterId: 10,
        requesterData: {
          'birthday': '2000-01-01',
        },
      );

      expect(result.name, 'Unknown User');
    });

  });
}