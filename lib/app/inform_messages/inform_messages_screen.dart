import 'package:agro/app/inform_messages/inform_message_card.dart';
import 'package:agro/app/inform_messages/inform_messages_controller.dart';
import 'package:agro/ui/app_components/app_background.dart';
import 'package:agro/ui/app_components/appbar_with_back.dart';
import 'package:agro/ui/app_components/empty_list_widget.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
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

  @override
  void initState() {
    super.initState();
    controller = Get.put(InformMessagesController());
    controller.initPage(context: context, set: setState);
  }

  @override
  void dispose() {
    Get.delete<InformMessagesController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = controller.sortedMessages;

    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: Column(
              children: [
              appBarBack( context.l.infoMessages),
                Expanded(
                  child: SmartRefresher(
                    controller: controller.refreshController,
                    enablePullDown: true,
                    enablePullUp: false,
                    onRefresh: controller.onRefresh,
                    header: const WaterDropHeader(
                      complete: _RefreshComplete(),
                      waterDropColor: AppColors.mainGreen,
                    ),
                    child: messages.isEmpty
                        ? emptyListDefault(context.l.emptyInformMessages, AppColors.darkGreen)
                          
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
                                onRead: () =>
                                    controller.onReadMessage(message),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshComplete extends StatelessWidget {
  const _RefreshComplete();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.done, color: Colors.grey),
        const SizedBox(width: 15),
        Text(
          context.l.updateComplete,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
