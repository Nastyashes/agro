import 'package:agro/controllers/app_input_controller.dart';
import 'package:agro/model/model_order/model_order.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/views/bottom_drawer_header.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

import '../../../../ui/buttons/b_style.dart';
import '../../../../ui/text_field/text_field.dart';
import 'order_controller.dart';

class AddPriceScreen extends StatefulWidget {
  const AddPriceScreen({super.key, required this.order});

  final ModelOrder order;

  @override
  State<AddPriceScreen> createState() => _AddPriceScreenState();
}

class _AddPriceScreenState extends State<AddPriceScreen> {
  TextEditingController priceController = AppInputController();
  OrderController controller = OrderController();
  Currency currency = Currency.uah;
  PaymentForm paymentForm = PaymentForm.f1;

  // Прибираємо ініціалізацію списків тут

  @override
  Widget build(BuildContext context) {
    // Ініціалізуємо списки в методі build, де context доступний
    final List<DropdownMenuItem<Currency>> currencies = Currency.values
        .map((e) => DropdownMenuItem(
            value: e,
            child: readText(
              text: e.text(context),
              size: 30,
              fontWeight: FontWeight.w500,
            )))
        .toList();

    final List<DropdownMenuItem<PaymentForm>> paymentForms = PaymentForm.values
        .map((e) => DropdownMenuItem(
            value: e,
            child: readText(
              text: e.labelLocalized(context),
              size: 30,
              fontWeight: FontWeight.w500,
            )))
        .toList();

    return Material(
      child: Container(
        height: 500 + MediaQuery.of(context).viewInsets.bottom,
        color: Colors.white,
        child: Column(
          children: [
            const BottomDrawerHeader(),
            readText(
                text: context.l.addPrice,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                size: 22,
                padding: const EdgeInsets.only(bottom: 30)),
            TextFieldWidget(
                padding: const EdgeInsets.all(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.transparent),
                text: context.l.price,
                suffixText: currency.label,
                openKeyboardAuto: true,
                colorBg: const Color(0xffF8F8F8),
                keyboardType: TextInputType.number,
                controller: priceController,
                sizeText: 30),
            Container(
                width: MediaQuery.of(context).size.width - 32,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    color: const Color(0xffF8F8F8),
                    borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<Currency>(
                  hint: readText(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      text: currency.text(context),
                      fontWeight: FontWeight.w500,
                      size: 30,
                      color: Colors.black),
                  isDense: false,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 40, color: Colors.black),
                  style: const TextStyle(color: Colors.black),
                  menuMaxHeight: 300,
                  items: currencies,
                  onChanged: (value) {
                    setState(() {
                      currency = value!;
                    });
                  },
                ))),
            const SizedBox(height: 15),
            Container(
                width: MediaQuery.of(context).size.width - 32,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    color: const Color(0xffF8F8F8),
                    borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<PaymentForm>(
                  hint: readText(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      text: paymentForm.labelLocalized(context),
                      fontWeight: FontWeight.w500,
                      size: 30,
                      color: Colors.black),
                  isDense: false,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 40, color: Colors.black),
                  style: const TextStyle(color: Colors.black),
                  menuMaxHeight: 300,
                  items: paymentForms,
                  onChanged: (value) {
                    setState(() {
                      paymentForm = value!;
                    });
                  },
                ))),
            bStyle(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
                text: context.l.addPrice,
                size: 23,
                c: context,
                colorText: Colors.white,
                vertical: 15,
                colorButt: const Color(0xffFCD300),
                onPressed: () =>
                    controller.onAddPriceSave(context, currency.json, paymentForm.json, priceController.text, widget.order.id!))
          ],
        ),
      ),
    );
  }
}

  Widget orderInfo({required String header, required String text}) => Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
      child: Row(children: [
        readText(text: header, color: const Color(0xffA9A9A9), size: 20),
        Expanded(
            child: readText(
                text: text,
                color: Colors.black,
                size: 20,
                fontWeight: FontWeight.w500,
                align: TextAlign.end))
      ]));


enum Currency {
  uah("₴", "currencyUah", "UAH"),
  usd("\$", "currencyUsd", "USD"),
  euro("€", "currencyEuro", "EUR");

  final String label;
  final String descriptionKey;
  final String json;

  // Використання map або switch для зіставлення ключів локалізації з властивостями AppLocalizations
  String text(BuildContext context) {
    String description = '';
    switch (this) {
      case Currency.uah:
        description = context.l.currencyUah;
        break;
      case Currency.usd:
        description = context.l.currencyUsd;
        break;
      case Currency.euro:
        description = context.l.currencyEuro;
        break;
    }
    return "$description ($label)";
  }

  const Currency(this.label, this.descriptionKey, this.json);
}

enum PaymentForm {
   f1("paymentFormF1", '1f'),
   f2("paymentFormF2", '2f');

  final String label;
  final String json;

  // Використання map або switch для зіставлення ключів локалізації з властивостями AppLocalizations
  String labelLocalized(BuildContext context) {
    String description = '';
    switch (this) {
      case PaymentForm.f1:
        description = context.l.paymentFormF1;
        break;
      case PaymentForm.f2:
        description = context.l.paymentFormF2;
        break;
    }
    return description;
  }

  const PaymentForm(this.label, this.json);
}



