import 'package:agro/ui/components/app_snackbar.dart';
import 'package:agro/app/inform_messages/inform_message_card.dart';
import 'package:agro/app/inform_messages/inform_messages_controller.dart';
import 'package:agro/ui/components/app_top_bar.dart';
import 'package:agro/ui/components/empty_state.dart';
import 'package:agro/ui/local_notification/local_notification.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class InformMessagesScreen extends StatefulWidget {
  const InformMessagesScreen({super.key});

  @override
  State<InformMessagesScreen> createState() => _InformMessagesScreenState();
}

class _InformMessagesScreenState extends State<InformMessagesScreen> {
  late final InformMessagesController controller;
  late final Worker _failureWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.put(InformMessagesController());
    _failureWorker = ever(controller.failures, (_) {
      if (mounted) {
        notification(text: context.l.somethingWentWrong, type: SnackType.error);
      }
    });
  }

  @override
  void dispose() {
    _failureWorker.dispose();
    Get.delete<InformMessagesController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      backgroundColor: Palette.bg0,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: l.messages),
            Expanded(
              child: SmartRefresher(
                controller: controller.refreshController,
                enablePullDown: true,
                enablePullUp: false,
                onRefresh: controller.onRefresh,
                header: const WaterDropHeader(
                  complete: _RefreshComplete(),
                  waterDropColor: Palette.green,
                ),
                child: Obx(() {
                  final messages = controller.sortedMessages;
                  return messages.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.only(top: 80),
                          children: [
                            controller.loadFailed.value
                                ? EmptyState(
                                    icon: Icons.cloud_off_rounded,
                                    title: l.loadFailedTitle,
                                    text: l.checkInternet,
                                    actionLabel: l.retry,
                                    onAction: controller.loadMessages,
                                  )
                                : EmptyState(
                                    title: l.emptyInformMessages,
                                    text: l.emptyMessagesText,
                                    icon: Icons.notifications_none_rounded,
                                  ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: messages.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return InformMessageCard(
                              key: ValueKey('msg_${message.id}'),
                              message: message,
                              onRead: () => controller.onReadMessage(message),
                            );
                          },
                        );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefreshComplete extends StatelessWidget {
  const _RefreshComplete();

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.done_rounded, color: Palette.textTertiary),
          const SizedBox(width: 12),
          Text(context.l.updateComplete,
              style: AppText.label.copyWith(color: Palette.textTertiary)),
        ],
      );
}
