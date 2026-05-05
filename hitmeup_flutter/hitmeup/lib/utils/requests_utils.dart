import 'package:hitmeup/services/api_config.dart';

class FriendRequestCardData {
  const FriendRequestCardData({
    required this.requestId,
    required this.requesterId,
    required this.name,
    required this.age,
    required this.level,
    required this.imageUrl,
    required this.diamonds,
  });

  final int requestId;
  final int requesterId;
  final String name;
  final int age;
  final int level;
  final String? imageUrl;
  final int diamonds;
}

class RequestsUtils {
  static FriendRequestCardData mapRequestToCard({
    required int requestId,
    required int requesterId,
    required Map<String, dynamic> requesterData,
  }) {
    final name = (requesterData['name'] as String?)?.trim();
    final birthdayRaw = (requesterData['birthday'] as String?)?.trim();
    final age = calculateAgeFromBirthday(birthdayRaw);
    final levelRaw = requesterData['level'];
    final level = levelRaw is int
        ? levelRaw
        : int.tryParse(levelRaw?.toString() ?? '') ?? 1;
    final diamondsRaw = requesterData['diamonds'];
    final diamonds = diamondsRaw is int
        ? diamondsRaw
        : int.tryParse(diamondsRaw?.toString() ?? '') ?? 0;

    return FriendRequestCardData(
      requestId: requestId,
      requesterId: requesterId,
      name: name != null && name.isNotEmpty ? name : 'Unknown User',
      age: age,
      level: level < 1 ? 1 : level,
      diamonds: diamonds,
      imageUrl: resolveProfilePictureUrl(
        (requesterData['profilepicture'] as String?)?.trim(),
      ),
    );
  }

  static int calculateAgeFromBirthday(String? birthdayRaw) {
    if (birthdayRaw == null || birthdayRaw.isEmpty) {
      return 0;
    }

    final birthday = DateTime.tryParse(birthdayRaw);
    if (birthday == null) {
      return 0;
    }

    final now = DateTime.now();
    var age = now.year - birthday.year;
    final hasHadBirthdayThisYear = now.month > birthday.month ||
        (now.month == birthday.month && now.day >= birthday.day);
    if (!hasHadBirthdayThisYear) {
      age -= 1;
    }
    return age < 0 ? 0 : age;
  }

  static String? resolveProfilePictureUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) {
      return null;
    }

    final normalizedRaw = rawUrl.replaceAll('\\', '/').trim();
    if (normalizedRaw.isEmpty) {
      return null;
    }

    final parsed = Uri.tryParse(normalizedRaw);
    final apiBase = Uri.parse(ApiConfig.baseUrl);

    if (parsed != null && parsed.hasScheme) {
      final isLocalHost =
          parsed.host == '127.0.0.1' || parsed.host == 'localhost';
      if (isLocalHost && apiBase.host != parsed.host) {
        return apiBase
            .replace(
              path: parsed.path,
              query: parsed.query,
              fragment: parsed.fragment,
            )
            .toString();
      }
      return normalizedRaw;
    }

    final base = Uri.parse('${ApiConfig.baseUrl}/');
    final withMediaPrefix =
        normalizedRaw.startsWith('/') ? normalizedRaw : '/media/$normalizedRaw';
    return base.resolve(withMediaPrefix).toString();
  }
}