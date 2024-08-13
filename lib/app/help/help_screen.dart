import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:agro/ui/text/read_text.dart';

import '../../generated/assets.dart';
import '../../ui/buttons/b_transparent_scalable_button.dart';
import '../components/block_page_screen.dart';
import 'components/help_controller.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    HelpController controller = Get.find();

    return BlockPageScreen(
        header: context.l.supportService,
        theme: SystemUiOverlayStyle.dark,
        child: Column(children: [
          readText(
              text: context.l.supportTeamText,
              heightText: 1.4,
              size: 18,
              color: Colors.black,
              padding: const EdgeInsets.only(top: 20)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            BTransparentScalableButton(onPressed: controller.onContactTelegram, scale: ScaleFormat.small, child: SvgPicture.asset(Assets.authTelegram, width: 60)),
            const SizedBox(width: 50),
            BTransparentScalableButton(onPressed: controller.onContactViber, scale: ScaleFormat.small, child: SvgPicture.asset(Assets.authViber, width: 60))
          ]),
          readText(
              text:
                  context.l.supportTeamTextEnd,
              heightText: 1.4,
              size: 18,
              color: Colors.black,
              padding: const EdgeInsets.only(top: 20)),
        ]));
  }
}
