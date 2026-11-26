import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';

/// Placeholder cards shaped like a bid card, gently pulsing, shown while
/// the first page of bids loads so the screen is never blank.
class BidListSkeleton extends StatefulWidget {
  const BidListSkeleton({super.key, this.count = 3});

  final int count;

  @override
  State<BidListSkeleton> createState() => _BidListSkeletonState();
}

class _BidListSkeletonState extends State<BidListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.45,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
        child: FadeTransition(
          opacity: _pulse,
          child: Column(children: [
            for (var i = 0; i < widget.count; i++) const _SkeletonCard(),
          ]),
        ),
      );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Palette.bg1,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: Palette.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _box(40, 40, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(90, 14),
                    const SizedBox(height: 8),
                    _box(150, 11),
                  ],
                ),
              ),
              _box(56, 22, radius: 6),
            ]),
            const SizedBox(height: 12),
            _box(double.infinity, 76, radius: 10),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _box(double.infinity, 44, radius: 100)),
              const SizedBox(width: 10),
              _box(44, 44, radius: 12),
            ]),
          ],
        ),
      );

  static Widget _box(double w, double h, {double radius = 6}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Palette.bg3,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
