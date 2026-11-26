import 'package:agro/model/message/message.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Message from UAGRO: unread ones have a green dot, a lighter card and a
/// "mark as read" action.
class InformMessageCard extends StatelessWidget {
  const InformMessageCard({super.key, required this.message, this.onRead});

  final Message message;
  final VoidCallback? onRead;

  @override
  Widget build(BuildContext context) {
    final unread = !message.isRead;
    final createdAt = message.createdAt;
    final date = createdAt == null
        ? null
        : DateFormat('dd.MM.yyyy HH:mm').format(createdAt);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      decoration: BoxDecoration(
        color: unread ? Palette.bg2 : Palette.bg1,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: Palette.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: unread ? Palette.green : Palette.bg3,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Text(message.title ?? '',
                        style: AppText.bodyMedium.copyWith(
                            color: unread
                                ? Palette.textPrimary
                                : Palette.textSecondary)),
                  ),
                  if (date != null) ...[
                    const SizedBox(width: 8),
                    Text(date,
                        style: AppText.caption
                            .copyWith(color: Palette.textTertiary)),
                  ],
                ]),
                const SizedBox(height: 6),
                Text(message.message ?? '',
                    style: AppText.body.copyWith(
                        color: unread
                            ? Palette.textSecondary
                            : Palette.textTertiary)),
                if (unread && onRead != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(48, 40),
                      ),
                      onPressed: onRead,
                      child: Text(context.l.markRead,
                          style: AppText.label.copyWith(color: Palette.green)),
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
