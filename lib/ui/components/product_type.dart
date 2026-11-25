import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Product sphere of a bid (`sphere_id` from the API).
enum ProductType {
  grain(15, Palette.typeGrain, 'picture/types/grain.svg'),
  fertilizer(12, Palette.typeFertilizer, 'picture/types/fertilizer.svg'),
  seeds(13, Palette.typeSeeds, 'picture/types/seeds.svg'),
  oil(14, Palette.typeOil, 'picture/types/oil.svg'),
  unknown(null, Palette.textSecondary, null);

  const ProductType(this.sphereId, this.color, this.asset);

  final int? sphereId;
  final Color color;
  final String? asset;

  static ProductType fromSphere(int? id) =>
      values.firstWhere((t) => t.sphereId != null && t.sphereId == id,
          orElse: () => unknown);

  String label(BuildContext context) => switch (this) {
        grain => context.l.typeGrain,
        fertilizer => context.l.typeFertilizer,
        seeds => context.l.typeSeeds,
        oil => context.l.typeOil,
        unknown => context.l.product,
      };
}

/// Rounded square with the product mark on a 16% tint of its color.
class TypeBadge extends StatelessWidget {
  const TypeBadge(this.type, {super.key, this.size = 40});

  final ProductType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mark = size * 0.6;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: type.asset == null
          ? Icon(Icons.inventory_2_outlined, size: mark, color: type.color)
          : SvgPicture.asset(type.asset!, width: mark, height: mark),
    );
  }
}
