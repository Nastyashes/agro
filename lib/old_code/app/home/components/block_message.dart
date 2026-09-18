import 'package:agro/app/inform_messages/inform_message_card.dart';
import 'package:agro/model/message/message.dart';
import 'package:flutter/material.dart';

class BlockMessage extends StatelessWidget {
  final Message message;
  final VoidCallback? onRead;

  const BlockMessage({
    super.key,
    required this.message,
    this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InformMessageCard(
        message: message,
        onRead: onRead,
      ),
    );
  }
}
