import 'package:agro/model/model_review/model_review.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';

/// Read-only row of five stars for a 1–5 rating.
class RatingStarsView extends StatelessWidget {
  const RatingStarsView({super.key, required this.rating, this.size = 18});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: i <= rating ? Palette.wheat : Palette.textTertiary,
            ),
        ],
      );
}

/// One review: its own rating (not always five), date and text.
class BlockReview extends StatelessWidget {
  final ModelReview modelReview;

  const BlockReview({super.key, required this.modelReview});

  @override
  Widget build(BuildContext context) {
    final rating = (modelReview.rating ?? 0).clamp(0, 5);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Palette.bg1,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: Palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            RatingStarsView(rating: rating),
            const Spacer(),
            if ((modelReview.date ?? '').isNotEmpty)
              Text(modelReview.date!,
                  style: AppText.caption.copyWith(color: Palette.textTertiary)),
          ]),
          if ((modelReview.comment ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(modelReview.comment!.trim(), style: AppText.body),
          ],
        ],
      ),
    );
  }
}
