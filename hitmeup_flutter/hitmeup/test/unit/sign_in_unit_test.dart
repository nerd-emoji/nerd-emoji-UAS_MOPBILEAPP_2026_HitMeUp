import 'package:flutter_test/flutter_test.dart';
import 'package:hitmeup/utils/sign_in_utils.dart';

void main() {
  test('parseUserObject returns map when JSON is object', () {
    final user = parseUserObject('{"id":1,"name":"Tester"}');
    expect(user, isNotNull);
    expect(user!['id'], 1);
    expect(user['name'], 'Tester');
  });

  test('parseUserObject returns null for non-object JSON', () {
    expect(parseUserObject('[1,2,3]'), isNull);
  });

  test('extractBackendError prefers detail field', () {
    expect(extractBackendError('{"detail":"Invalid password"}'), 'Invalid password');
  });

  test('extractBackendError falls back to trimmed plain text', () {
    expect(extractBackendError('  bad gateway  '), 'bad gateway');
  });

  test('isCredentialError classifies auth failures', () {
    expect(isCredentialError(401, 'anything'), isTrue);
    expect(isCredentialError(500, 'invalid password'), isTrue);
    expect(isCredentialError(500, 'server error'), isFalse);
  });

  test('buildLoginErrorMessage formats error text', () {
    expect(buildLoginErrorMessage(401, 'anything'), 'Incorrect username or password');
    expect(buildLoginErrorMessage(500, 'Server down'), 'Login failed (500): Server down');
  });
}
