import 'package:agro/model/tariff/model_tariff.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

/// One tariff card in the swipeable list: tinted head with the name,
/// price, then what is included and what is not.
class TariffItem extends StatelessWidget {
  const TariffItem(
      {super.key, required this.modelTariff, required this.isMyTariff});

  final ModelTariff modelTariff;
  final bool isMyTariff;

  @override
  Widget build(BuildContext context) {
    final color = modelTariff.color;
    final soft = color.withValues(alpha: 0.13);
    final isByPiece =
        modelTariff.name?.toUpperCase() == AppConstants.tariffByPieceName;
    final oldPrice = modelTariff.priceOld ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Palette.bg1,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: soft,
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.workspace_premium_rounded, size: 28, color: color),
                  const Spacer(),
                  if (isMyTariff)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(context.l.myTariff,
                          style:
                              AppText.tag.copyWith(color: Palette.textInverse)),
                    ),
                ]),
                const SizedBox(height: 6),
                Text(modelTariff.name ?? '', style: AppText.display),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (oldPrice != 0)
                  Text(
                    context.uahAmount(oldPrice),
                    style: AppText.num.copyWith(
                      color: Palette.textTertiary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text.rich(TextSpan(children: [
                  if (isByPiece)
                    TextSpan(
                        text: '${context.l.validFrom} ',
                        style: AppText.title.copyWith(color: color)),
                  TextSpan(
                      text: modelTariff.price ?? '',
                      style: AppText.numXL.copyWith(color: color)),
                  TextSpan(
                      text: ' ${modelTariff.currency ?? ''}',
                      style: AppText.title.copyWith(color: color)),
                ])),
                if (isSet(modelTariff.pricePeriod))
                  Text(modelTariff.pricePeriod!,
                      style:
                          AppText.label.copyWith(color: Palette.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
              children: [
                for (final a in modelTariff.advantages)
                  _Feature(text: a, ok: true, color: color),
                for (final d in modelTariff.disadvantages)
                  _Feature(text: d, ok: false, color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.text, required this.ok, required this.color});

  final String text;
  final bool ok;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: ok ? color.withValues(alpha: 0.13) : Palette.redSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(ok ? Icons.check_rounded : Icons.close_rounded,
                  size: 16, color: ok ? color : Palette.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: AppText.bodyMedium.copyWith(
                      color: ok ? Palette.textPrimary : Palette.textTertiary)),
            ),
          ],
        ),
      );
}
