import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/utils/community_utils.dart';

void main() {
  group('Community utils', () {
    test('resolveCommunityImageUrl returns fallback asset for empty input', () {
      expect(resolveCommunityImageUrl(null), 'assets/FallBackProfile.png');
      expect(resolveCommunityImageUrl('   '), 'assets/FallBackProfile.png');
    });

    test('resolveCommunityImageUrl keeps absolute urls', () {
      expect(
        resolveCommunityImageUrl('https://example.com/a.png'),
        'https://example.com/a.png',
      );
    });

    test('mapCommunitiesFromApi maps and normalizes data', () {
      final rows = mapCommunitiesFromApi([
        {
          'id': 1,
          'name': 'Sample Community',
          'description': 'A place for testing',
          'totalParticipants': 12,
          'communityPicture': null,
        },
      ]);

      expect(rows, hasLength(1));
      expect(rows.first.title, 'Sample Community');
      expect(rows.first.subtitle, 'A place for testing  •  12 users');
      expect(rows.first.isAsset, true);
      expect(rows.first.imageUrl, 'assets/FallBackProfile.png');
    });

    test('filterCommunities filters by title and description', () {
      final rows = [
        const CommunityRowData(
          id: 1,
          title: 'Sample Community',
          description: 'A place for testing',
          participants: '12 users',
          imageUrl: 'assets/FallBackProfile.png',
        ),
        const CommunityRowData(
          id: 2,
          title: 'Other Community',
          description: 'Another testing space',
          participants: '5 users',
          imageUrl: 'assets/FallBackProfile.png',
        ),
      ];

      expect(filterCommunities(rows, 'other'), hasLength(1));
      expect(filterCommunities(rows, 'space').first.id, 2);
      expect(filterCommunities(rows, ''), hasLength(2));
    });
  });
}