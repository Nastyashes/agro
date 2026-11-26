import 'package:agro/ui/app_components/app_background.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../generated/assets.dart';

class LoadScreen extends StatelessWidget {
  const LoadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Palette.bg0,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            const AppBackground(),
            Align(
                alignment: Alignment.center,
                child: Image.asset(Assets.pictureLogo,
                    width: MediaQuery.of(context).size.width / 1.4)),
          ],
        ));
  }
}

class AppCircularProgressIndicator extends StatelessWidget {
  final double? size;
  final Color? color;

  const AppCircularProgressIndicator({Key? key, this.size, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
            width: size ?? 100,
            child: LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [
                  color ?? Colors.grey.shade300,
                  color ?? Colors.grey.shade300
                ],
                strokeWidth: 2,
                backgroundColor: Colors.transparent,
                pathBackgroundColor: Colors.transparent)));
  }
}
