import 'package:agro/server/api/api.dart';
import 'package:agro/server/api/api_client.dart';

/// Outcome of entering the SMS code.
class ConfirmCodeResult {
  const ConfirmCodeResult.success({required this.user, required this.token})
      : errorMessage = null;

  const ConfirmCodeResult.failure(this.errorMessage)
      : user = null,
        token = null;

  final Map<String, dynamic>? user;
  final String? token;

  /// Server text to show when the code is rejected.
  final String? errorMessage;

  bool get isSuccess => token != null;
}

/// Phone/SMS and QR sign-in. Never logs tokens or codes.
///
/// Like the legacy code, phone/code results depend on the JSON `status`, not
/// the HTTP status, so a JSON error body is still read.
class AuthRepository {
  AuthRepository([Api? api]) : _api = api ?? Api();

  final Api _api;

  /// Asks the server to send an SMS code; false if the number is unknown.
  Future<bool> requestCode(String phone) async {
    final data = (await _api.auth.loginNumber(number: phone)).data;
    return data is Map && data['status'] == true;
  }

  Future<ConfirmCodeResult> confirmCode(String code) async {
    final data = (await _api.auth.loginCode(code: code)).data;
    if (data is! Map || data['status'] != true) {
      return ConfirmCodeResult.failure(
          data is Map ? data['message']?.toString() : null);
    }

    final payload = data['payload'];
    final user = payload is Map ? payload['user'] : null;
    final token = payload is Map ? payload['key'] : null;
    if (user is! Map || token == null) {
      throw const ApiException(ApiErrorKind.badResponse, statusCode: 200);
    }
    return ConfirmCodeResult.success(
      user: Map<String, dynamic>.from(user),
      token: token.toString(),
    );
  }

  /// Signs the web session in with a QR secret scanned in the app.
  Future<bool> loginWithQr(String secret) async {
    final answer = await _api.traider.loginWithQr(secret);
    return answer.code == 200;
  }
}
