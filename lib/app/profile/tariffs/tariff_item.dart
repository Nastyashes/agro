import 'package:agro/model/tariff/model_tariff.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/app_constants.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

/// One tariff card in the swipeable list: a gradient frame and glow in
/// the tariff colour, name and price, then what is included and what not.
class TariffItem extends StatelessWidget {
  const TariffItem(
      {super.key, required this.modelTariff, required this.isMyTariff});

  final ModelTariff modelTariff;
  final bool isMyTariff;

  @override
  Widget build(BuildContext context) {
    final color = modelTariff.color;
    final light = Color.lerp(color, Colors.white, 0.35)!;
    final isByPiece =
        modelTariff.name?.toUpperCase() == AppConstants.tariffByPieceName;
    final oldPrice = modelTariff.priceOld ?? 0;
    const radius = 28.0;

    // Gradient frame: the tariff colour fading into the card edge.
    return Container(
      margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: isMyTariff ? 0.55 : 0.25),
            Palette.line,
          ],
          stops: const [0, 0.45, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isMyTariff ? 0.28 : 0.12),
            blurRadius: 28,
            spreadRadius: -6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1.5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // Opaque tones: a translucent top let the bright frame
              // gradient show through and wash the header text out.
              colors: [
                Color.alphaBlend(color.withValues(alpha: 0.16), Palette.bg1),
                Palette.bg1,
                Palette.bg1,
              ],
              stops: const [0, 0.38, 1],
            ),
          ),
          child: Stack(children: [
            // Soft glow behind the header.
            Positioned(
              top: -90,
              right: -70,
              child: IgnorePointer(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      color.withValues(alpha: 0.16),
                      color.withValues(alpha: 0),
                    ]),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [light, color],
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 14),
                        ],
                      ),
                      child: const Icon(Icons.workspace_premium_rounded,
                          size: 24, color: Palette.textInverse),
                    ),
                    const Spacer(),
                    if (isMyTariff)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        // Solid, high-contrast: the user's current plan.
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [light, color]),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                                color: color.withValues(alpha: 0.45),
                                blurRadius: 12),
                          ],
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 15, color: Palette.textInverse),
                          const SizedBox(width: 5),
                          Text(context.l.myTariff,
                              style: AppText.label.copyWith(
                                  color: Palette.textInverse,
                                  fontWeight: FontWeight.w800)),
                        ]),
                      ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                  child: Text(modelTariff.name ?? '',
                      style: AppText.display.copyWith(fontSize: 28)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (oldPrice != 0)
                        Text(
                          context.uahAmount(oldPrice),
                          style: AppText.num.copyWith(
                            color: Palette.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (b) => LinearGradient(
                          colors: [light, color],
                        ).createShader(b),
                        child: Text.rich(TextSpan(children: [
                          if (isByPiece)
                            TextSpan(
                                text: '${context.l.validFrom} ',
                                style: AppText.title),
                          TextSpan(
                              text: modelTariff.price ?? '',
                              style: AppText.numXL),
                          TextSpan(
                              text: ' ${modelTariff.currency ?? ''}',
                              style: AppText.title),
                        ])),
                      ),
                      if (isSet(modelTariff.pricePeriod))
                        Text(modelTariff.pricePeriod!,
                            style: AppText.bodyMedium
                                .copyWith(color: Palette.textPrimary)),
                    ],
                  ),
                ),
                // Gradient hairline instead of a flat divider.
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      color.withValues(alpha: 0.7),
                      color.withValues(alpha: 0),
                    ]),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
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
          ]),
        ),
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
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: ok ? color.withValues(alpha: 0.16) : Palette.bg3,
                shape: BoxShape.circle,
                border: Border.all(
                    color:
                        ok ? color.withValues(alpha: 0.5) : Palette.lineStrong),
              ),
              child: Icon(ok ? Icons.check_rounded : Icons.close_rounded,
                  size: 14, color: ok ? color : Palette.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: AppText.bodyMedium.copyWith(
                      color: ok ? Palette.textPrimary : Palette.textSecondary)),
            ),
          ],
        ),
      );
}
