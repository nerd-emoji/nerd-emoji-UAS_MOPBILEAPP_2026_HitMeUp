int calculateAgeFromBirthday(String? birthdayRaw) {
  if (birthdayRaw == null || birthdayRaw.isEmpty) {
    return 0;
  }

  final birthday = DateTime.tryParse(birthdayRaw);
  if (birthday == null) {
    return 0;
  }

  final now = DateTime.now();
  var age = now.year - birthday.year;

  final hasHadBirthdayThisYear =
      now.month > birthday.month ||
      (now.month == birthday.month && now.day >= birthday.day);

  if (!hasHadBirthdayThisYear) {
    age -= 1;
  }

  return age < 0 ? 0 : age;
}

bool matchesWantToMeetPreference({
  required String? wantToMeetRaw,
  required dynamic candidateGenderRaw,
}) {
  final wantToMeet = (wantToMeetRaw ?? '').toLowerCase().trim();
  final candidateGender =
      (candidateGenderRaw?.toString() ?? '').toLowerCase().trim();

  switch (wantToMeet) {
    case 'man':
      return candidateGender == 'male' || candidateGender == 'man';
    case 'woman':
      return candidateGender == 'female' || candidateGender == 'woman';
    case 'everyone':
    case 'anyone':
    case '':
      return true;
    default:
      return true;
  }
}

List<int> extractUserIds(dynamic rawUsers) {
  if (rawUsers is! List) {
    return [];
  }

  final ids = <int>[];

  for (final item in rawUsers) {
    if (item is int) {
      ids.add(item);
    } else if (item is String) {
      final parsed = int.tryParse(item);
      if (parsed != null) ids.add(parsed);
    } else if (item is Map<String, dynamic>) {
      final rawId = item['id'];
      final parsed =
          rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
      if (parsed != null) ids.add(parsed);
    }
  }

  return ids;
}

String? resolveProfilePictureUrl(String? rawUrl, String baseUrl) {
  if (rawUrl == null || rawUrl.isEmpty) return null;

  final normalized = rawUrl.replaceAll('\\', '/').trim();
  if (normalized.isEmpty) return null;

  final parsed = Uri.tryParse(normalized);
  final apiBase = Uri.parse(baseUrl);

  if (parsed != null && parsed.hasScheme) {
    final isLocal =
        parsed.host == '127.0.0.1' || parsed.host == 'localhost';

    if (isLocal && apiBase.host != parsed.host) {
      return apiBase
          .replace(
            path: parsed.path,
            query: parsed.query,
            fragment: parsed.fragment,
          )
          .toString();
    }
    return normalized;
  }

  final base = Uri.parse('$baseUrl/');
  final path =
      normalized.startsWith('/') ? normalized : '/media/$normalized';

  return base.resolve(path).toString();
}