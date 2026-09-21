import 'package:agro/generated/assets.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentGeometry.topCenter,
            end: AlignmentGeometry.bottomRight,
            colors: [
              AppColors.backgroundGradient1,
              AppColors.backgroundGradient2,
              AppColors.backgroundGradient2,
              AppColors.backgroundGradient3.withValues(alpha: 0.7),
            ],
            stops: const [0.0, 0.1, 0.85, 1.0],
          ),
        ),
        height: double.infinity,
        width: double.infinity,
        child: Align(
          alignment: AlignmentGeometry.bottomCenter,
          child: Opacity(
            opacity: 0.2, // від 0.0 до 1.0
            child: Image.asset(Assets.bgZerno),
          ),
        ));
  }
}
