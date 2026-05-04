import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/services/api_config.dart';

class _ChatScreenState {
  String _resolveCommunityImageUrl(dynamic rawPath) {
    final value = (rawPath ?? '').toString().trim();
    if (value.isEmpty) {
      return 'assets/FallBackProfile.png';
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }

  String _resolveProfileImageUrl(dynamic rawPath) {
    final value = (rawPath ?? '').toString().trim();
    if (value.isEmpty) {
      return 'assets/FallBackProfile.png';
    }
    if (value.startsWith('assets/')) {
      return value;
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }
}

void main() {

  group('Chat Utils Test', () {

    late dynamic state;

    setUp(() {
      state = _ChatScreenState();
    });

    // ---------------------------
    // PROFILE IMAGE URL
    // ---------------------------

    test('return fallback if empty profile image', () {
      final result = state._resolveProfileImageUrl(null);

      expect(result, 'assets/FallBackProfile.png');
    });

    test('return asset path if already asset', () {
      final result = state._resolveProfileImageUrl('assets/test.png');

      expect(result, 'assets/test.png');
    });

    test('return full url if already absolute', () {
      final result = state._resolveProfileImageUrl('https://example.com/img.png');

      expect(result, 'https://example.com/img.png');
    });

    test('convert relative path to full url', () {
      final result = state._resolveProfileImageUrl('media/img.png');

      expect(result.contains('http'), true);
    });

    // ---------------------------
    // COMMUNITY IMAGE URL
    // ---------------------------

    test('return fallback if empty community image', () {
      final result = state._resolveCommunityImageUrl(null);

      expect(result, 'assets/FallBackProfile.png');
    });

    test('return full url if already absolute (community)', () {
      final result = state._resolveCommunityImageUrl('https://example.com/img.png');

      expect(result, 'https://example.com/img.png');
    });

    test('convert relative path to full url (community)', () {
      final result = state._resolveCommunityImageUrl('community/img.png');

      expect(result.contains('http'), true);
    });

  });
}