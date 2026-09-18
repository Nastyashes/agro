import 'package:agro/ui/buttons/button_styles.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget offerItem(int index, String date, String url, BuildContext context) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        readText(text: "$index.", style: AppFonts.body1medium.grey3),
        const SizedBox(width: 10),
        Expanded(
            child: readText(text: date, style: AppFonts.body1medium.black)),
       ElevatedButton(
  style: outlineButtonStyle,
            child: Text( context.l.download),
            onPressed: () {
              launchUrl(Uri.parse(url));
            }),
      ]));
}
