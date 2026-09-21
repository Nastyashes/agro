import 'package:agro/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerItemForList extends StatelessWidget {
  const BannerItemForList({
    super.key,
    required this.imageUrl,
    this.phoneNumber,
    this.onTapUrl,
  });

  final String imageUrl;
  final String? phoneNumber;
  final String? onTapUrl;

  Future<void> _handleTap() async {
    if (onTapUrl != null) {
      final uri = Uri.parse(onTapUrl!);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      final uri = Uri.parse('tel:$phoneNumber');
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: GestureDetector(
            onTap: _handleTap,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.zerno,
                  ),
                ),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(23.5)),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;

                      return const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (_, __, ___) {
                      return const SizedBox(
                        height: 120,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ))));
  }
}
