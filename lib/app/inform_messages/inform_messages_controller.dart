import 'dart:developer';

import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/data/repositories/messages_repository.dart';
import 'package:agro/app/new_home_screen/new_home_screen_controler.dart';
import 'package:agro/model/message/message.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class InformMessagesController extends BaseController {
  late BuildContext context;
  late Function(VoidCallback fn) setState;

  late final RefreshController refreshController;

  final MessagesRepository _repository = MessagesRepository();

  List<Message> messages = [];

  bool _isLoadingMessages = false;

  int get unreadCount => messages.where((message) => !message.isRead).length;

  @override
  void onInit() {
    refreshController = RefreshController();
    super.onInit();
  }

  void initPage({
    required BuildContext context,
    required Function(VoidCallback fn) set,
  }) {
    this.context = context;
    setState = set;
    loadMessages();
  }

  List<Message> get sortedMessages {
    final unread = messages.where((m) => !m.isRead).toList();
    final read = messages.where((m) => m.isRead).toList();

    unread.sort(_byDateDesc);
    read.sort(_byDateDesc);

    return [...unread, ...read];
  }

  int _byDateDesc(Message a, Message b) {
    return (b.createdAt?.millisecondsSinceEpoch ?? 0)
        .compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0);
  }

  Future<void> loadMessages() async {
    if (_isLoadingMessages) return;
    _isLoadingMessages = true;

    try {
      final loaded = await _repository.fetchAll();

      messages
        ..clear()
        ..addAll(loaded);
      _publishUnreadCount();

      if (context.mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      log(
        'InformMessagesController loadMessages error: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'InformMessages',
      );

      if (context.mounted) {
        notification(text: context.l.somethingWentWrong);
      }
    } finally {
      _isLoadingMessages = false;
    }
  }

  void _publishUnreadCount() {
    if (!Get.isRegistered<NewHomeController>()) return;
    Get.find<NewHomeController>().unreadInformCount.value = unreadCount;
  }

  Future<void> onReadMessage(Message message) async {
    try {
      await _repository.markRead(message.id);
      await loadMessages();
    } catch (e, stackTrace) {
      log(
        'InformMessagesController onReadMessage error: $e',
        error: e,
        stackTrace: stackTrace,
      );

      if (context.mounted) {
        notification(text: context.l.somethingWentWrong);
      }
    }
  }

  Future<void> onRefresh() async {
    try {
      await loadMessages();
      refreshController.refreshCompleted();
    } catch (_) {
      refreshController.refreshFailed();
    }
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
