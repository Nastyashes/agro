import 'package:agro/old_code/app/home/order/components/phone_number_item.dart';
import 'package:agro/model/model_order/traider_contact.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

Widget traiderContacts(List<TraiderContact> contacts, bool canOpenPhone, Function(String) onLaunchPhone, BuildContext context) {
  return Column(
    children: [
      readText(
        text: context.l.openedByTraders,
        style: AppFonts.body1bold.black,
      ),
      const SizedBox(height: 10),
        for (int i = 0; i < contacts.length; i++) ...[
          PhoneNumberItem(
          index: i + 1,
          canOpenPhone: canOpenPhone,
          date: contacts[i].date ?? "",
          number: contacts[i].phone ?? "",
          onPhoneClick: () {
            onLaunchPhone(contacts[i].phone ?? "");
          })
      ]
    ]
  );
}
