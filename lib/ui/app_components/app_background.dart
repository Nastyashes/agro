import 'package:agro/ui/theme/colors.dart';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentGeometry.topCenter,
          end: AlignmentGeometry.bottomCenter,
          colors: [
          AppColors.backgroundGradient1,
          AppColors.backgroundGradient2,
          AppColors.backgroundGradient3,
        ], stops: [
          0.0,
          0.76,
          1.0
        ]),
      ),
      height: double.infinity,
      width: double.infinity,
    );
  }
}
