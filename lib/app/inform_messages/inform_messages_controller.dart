import 'dart:developer';

import 'package:agro/controllers/abstract/base_controller.dart';
import 'package:agro/model/message/message.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class InformMessagesController extends BaseController {
  late BuildContext context;
  late Function(VoidCallback fn) setState;

  late final RefreshController refreshController;

  List<Message> messages = [];

  bool _isLoadingMessages = false;

  int get unreadCount =>
      messages.where((message) => !message.isRead).length;

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
      final apiAnswer = await Api().traider.getMessages();
      final loaded = _parseMessages(apiAnswer.data);

      messages
        ..clear()
        ..addAll(loaded);

      if (context.mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      log(
        'InformMessagesController loadMessages error: $e',
        error: e,
        stackTrace: stackTrace,
      );

      if (context.mounted) {
        notification(text: context.l.somethingWentWrong);
      }
    } finally {
      _isLoadingMessages = false;
    }
  }

  List<Message> _parseMessages(dynamic data) {
    final List<dynamic> raw;

    if (data is List) {
      raw = data;
    } else if (data is Map && data['payload'] is List) {
      raw = data['payload'] as List;
    } else {
      raw = const [];
    }

    return [
      for (final item in raw)
        if (item is Map<String, dynamic>)
          Message.fromJson(item)
        else if (item is Map)
          Message.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  Future<void> onReadMessage(Message message) async {
    try {
      await Api().traider.readMessage(message.id);
      log('read message ${message.id}');
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
