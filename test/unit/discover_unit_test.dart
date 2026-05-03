import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/utils/discover_utils.dart';

void main() {

  group('Age Test', () {
    test('valid date', () {
      final age = calculateAgeFromBirthday('2000-01-01');
      expect(age, greaterThan(20));
    });

    test('null', () {
      expect(calculateAgeFromBirthday(null), 0);
    });

    test('invalid', () {
      expect(calculateAgeFromBirthday('abc'), 0);
    });

    test('future date', () {
      expect(calculateAgeFromBirthday('3000-01-01'), 0);
    });
  });

  group('Preference Test', () {
    test('man preference', () {
      expect(
        matchesWantToMeetPreference(
          wantToMeetRaw: 'man',
          candidateGenderRaw: 'male',
        ),
        true,
      );
    });

    test('woman preference', () {
      expect(
        matchesWantToMeetPreference(
          wantToMeetRaw: 'woman',
          candidateGenderRaw: 'female',
        ),
        true,
      );
    });

    test('everyone', () {
      expect(
        matchesWantToMeetPreference(
          wantToMeetRaw: 'everyone',
          candidateGenderRaw: 'male',
        ),
        true,
      );
    });

    test('mismatch', () {
      expect(
        matchesWantToMeetPreference(
          wantToMeetRaw: 'man',
          candidateGenderRaw: 'female',
        ),
        false,
      );
    });
  });

  group('Extract User IDs', () {
    test('int list', () {
      expect(extractUserIds([1, 2, 3]), [1, 2, 3]);
    });

    test('string list', () {
      expect(extractUserIds(['1', '2']), [1, 2]);
    });

    test('map list', () {
      expect(
        extractUserIds([
          {'id': 1},
          {'id': '2'}
        ]),
        [1, 2],
      );
    });

    test('invalid', () {
      expect(extractUserIds(null), []);
    });
  });

  group('Resolve URL', () {
    const baseUrl = 'http://example.com';

    test('absolute url', () {
      final result =
          resolveProfilePictureUrl('http://image.com/a.png', baseUrl);
      expect(result, 'http://image.com/a.png');
    });

    test('relative url', () {
      final result =
          resolveProfilePictureUrl('image.png', baseUrl);
      expect(result, contains('/media/image.png'));
    });

    test('null', () {
      expect(resolveProfilePictureUrl(null, baseUrl), null);
    });
  });
}