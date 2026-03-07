import 'package:farm_buddy_app/services/auth_ui_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthUiService.isUnauthorizedError', () {
    test('returns true for HTTP 401 message', () {
      expect(
        AuthUiService.isUnauthorizedError(Exception('Request failed: 401')),
        isTrue,
      );
    });

    test('returns true for unauthorized message', () {
      expect(
        AuthUiService.isUnauthorizedError(Exception('Unauthorized access')),
        isTrue,
      );
    });

    test('returns true for forbidden message', () {
      expect(
        AuthUiService.isUnauthorizedError(Exception('Forbidden resource')),
        isTrue,
      );
    });

    test('returns false for non-auth failures', () {
      expect(
        AuthUiService.isUnauthorizedError(Exception('Network timeout')),
        isFalse,
      );
    });
  });
}
