import 'dart:convert';

Map<String, dynamic>? parseUserObject(String responseBody) {
  try {
    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (_) {
    // Intentionally ignored.
  }
  return null;
}

String extractBackendError(String responseBody) {
  try {
    final decoded = jsonDecode(responseBody);
    if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
    }
  } catch (_) {
    // Keep fallback below.
  }

  final trimmed = responseBody.trim();
  if (trimmed.isNotEmpty) {
    return trimmed;
  }

  return 'Please check your credentials.';
}

bool isCredentialError(int statusCode, String backendError) {
  final normalizedBackendError = backendError.toLowerCase();
  return statusCode == 401 ||
      statusCode == 403 ||
      normalizedBackendError.contains('invalid username') ||
      normalizedBackendError.contains('invalid password') ||
      (normalizedBackendError.contains('invalid') &&
          normalizedBackendError.contains('password'));
}

String buildLoginErrorMessage(int statusCode, String backendError) {
  return isCredentialError(statusCode, backendError)
      ? 'Incorrect username or password'
      : 'Login failed ($statusCode): $backendError';
}
