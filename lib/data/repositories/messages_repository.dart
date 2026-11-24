import 'package:agro/model/message/message.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/server/api/api_client.dart';

/// Informational messages (push history) of the current user.
///
/// Returns models only; any failure (network, non-200, bad JSON) is an
/// [ApiException].
class MessagesRepository {
  MessagesRepository([Api? api]) : _api = api ?? Api();

  final Api _api;

  Future<List<Message>> fetchAll() async {
    final answer = _ok(await _api.traider.getMessages());
    return parseMessagesPayload(answer.data);
  }

  Future<int> unreadCount() async =>
      (await fetchAll()).where((m) => !m.isRead).length;

  Future<void> markRead(int? id) async {
    _ok(await _api.traider.readMessage(id));
  }

  static ApiAnswer _ok(ApiAnswer answer) {
    if (answer.code != 200) {
      throw ApiException(ApiErrorKind.badResponse, statusCode: answer.code);
    }
    return answer;
  }
}
