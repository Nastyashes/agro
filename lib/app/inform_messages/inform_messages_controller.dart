import 'dart:developer';

import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/data/repositories/messages_repository.dart';
import 'package:agro/model/message/message.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Informational messages screen state. Holds no BuildContext: the screen
/// observes [messages] and turns [failures] into a user-facing message.
class InformMessagesController extends BaseController {
  InformMessagesController({
    MessagesRepository? repository,
    void Function(int unread)? onUnreadChanged,
  })  : _repository = repository ?? MessagesRepository(),
        _onUnreadChanged = onUnreadChanged ?? _publishToHome;

  final MessagesRepository _repository;
  final void Function(int unread) _onUnreadChanged;

  final RefreshController refreshController = RefreshController();

  final RxList<Message> messages = <Message>[].obs;

  /// Incremented on every failed load/read; the screen shows an error.
  final RxInt failures = 0.obs;

  /// Messages could not be loaded: not the same as "no messages".
  final RxBool loadFailed = false.obs;

  bool _isLoadingMessages = false;

  int get unreadCount => messages.where((m) => !m.isRead).length;

  /// Unread first, newest first within each group.
  List<Message> get sortedMessages {
    final unread = messages.where((m) => !m.isRead).toList()..sort(_byDateDesc);
    final read = messages.where((m) => m.isRead).toList()..sort(_byDateDesc);
    return [...unread, ...read];
  }

  @override
  void onReady() {
    super.onReady();
    loadMessages();
  }

  Future<void> loadMessages() async {
    if (_isLoadingMessages) return;
    _isLoadingMessages = true;

    try {
      messages.assignAll(await _repository.fetchAll());
      loadFailed.value = false;
      _onUnreadChanged(unreadCount);
    } catch (e, stackTrace) {
      log('InformMessagesController loadMessages error: $e',
          error: e, stackTrace: stackTrace, name: 'InformMessages');
      if (messages.isEmpty) loadFailed.value = true;
      failures.value++;
    } finally {
      _isLoadingMessages = false;
    }
  }

  Future<void> onReadMessage(Message message) async {
    try {
      await _repository.markRead(message.id);
    } catch (e, stackTrace) {
      log('InformMessagesController onReadMessage error: $e',
          error: e, stackTrace: stackTrace, name: 'InformMessages');
      failures.value++;
      return;
    }
    await loadMessages();
  }

  Future<void> onRefresh() async {
    final before = failures.value;
    await loadMessages();
    if (failures.value == before) {
      refreshController.refreshCompleted();
    } else {
      refreshController.refreshFailed();
    }
  }

  static int _byDateDesc(Message a, Message b) =>
      (b.createdAt?.millisecondsSinceEpoch ?? 0)
          .compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0);

  static void _publishToHome(int unread) {
    if (!Get.isRegistered<NewHomeController>()) return;
    Get.find<NewHomeController>().unreadInformCount.value = unread;
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
