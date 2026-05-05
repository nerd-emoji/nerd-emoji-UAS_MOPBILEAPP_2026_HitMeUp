import 'package:hitmeup/services/api_config.dart';

class CommunityRowData {
  const CommunityRowData({
    required this.id,
    required this.title,
    required this.description,
    required this.participants,
    required this.imageUrl,
    this.isAsset = false,
  });

  final int id;
  final String title;
  final String description;
  final String participants;
  final String imageUrl;
  final bool isAsset;

  String get subtitle => '$description  •  $participants';
}

List<CommunityRowData> mapCommunitiesFromApi(
  List<Map<String, dynamic>> communities,
) {
  return communities.map((community) {
    final hasImage = community['communityPicture'] != null;
    return CommunityRowData(
      id: community['id'] is int
          ? community['id'] as int
          : int.tryParse(community['id'].toString()) ?? 0,
      title: community['name']?.toString() ?? 'Unknown Community',
      description: community['description']?.toString() ?? 'No description',
      participants: '${community['totalParticipants'] ?? 0} users',
      imageUrl: hasImage
          ? resolveCommunityImageUrl(community['communityPicture']?.toString())
          : 'assets/FallBackProfile.png',
      isAsset: !hasImage,
    );
  }).toList();
}

List<CommunityRowData> filterCommunities(
  List<CommunityRowData> communities,
  String query,
) {
  final normalizedQuery = query.toLowerCase();
  if (normalizedQuery.isEmpty) {
    return List<CommunityRowData>.from(communities);
  }

  return communities.where((community) {
    return community.title.toLowerCase().contains(normalizedQuery) ||
        community.description.toLowerCase().contains(normalizedQuery);
  }).toList();
}

String extractBaseUrl() {
  return ApiConfig.baseUrl;
}

String resolveCommunityImageUrl(String? rawPath) {
  final value = (rawPath ?? '').trim();
  if (value.isEmpty) {
    return 'assets/FallBackProfile.png';
  }

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }

  final base = extractBaseUrl().replaceAll(RegExp(r'/+$'), '');
  final path = value.startsWith('/') ? value : '/$value';
  return '$base$path';
}