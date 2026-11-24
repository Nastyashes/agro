import 'package:agro/model/message/message.dart';
import 'package:agro/ui/buttons/button_styles.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InformMessageCard extends StatelessWidget {
  final Message message;
  final VoidCallback? onRead;

  const InformMessageCard({
    super.key,
    required this.message,
    this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = message.createdAt;
    final dateText = createdAt == null
        ? null
        : DateFormat('dd.MM.yyyy HH:mm').format(createdAt);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundGradient1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: message.isRead
              ? AppColors.mainGreen.withValues(alpha: 0.3)
              : AppColors.mainGreen,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.title ?? '',
            style: AppFonts.body1semibold.white,
          ),
          if (dateText != null) ...[
            const SizedBox(height: 4),
            Text(
              dateText,
              style: AppFonts.caption.grey3,
            ),
          ],
          const SizedBox(height: 10),
          Text(
            message.message ?? '',
            style: AppFonts.body2medium.grey3,
          ),
          if (!message.isRead && onRead != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: greenButtonStyle,
                onPressed: onRead,
                child: Text(
                  context.l.read,
                  style: AppFonts.body2bold.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
