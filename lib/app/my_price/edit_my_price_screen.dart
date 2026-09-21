import 'package:agro/app/my_price/components/my_price_dialogs.dart';
import 'package:agro/app/my_price/controller/edit_my_price_controller.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/ui/app_components/app_background.dart';
import 'package:agro/ui/app_components/appbar_with_back.dart';
import 'package:agro/ui/buttons/button_styles.dart';
import 'package:agro/ui/text_field/text_field.dart';
import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditMyPriceScreen extends StatefulWidget {
  const EditMyPriceScreen({super.key});

  @override
  State<EditMyPriceScreen> createState() => _EditMyPriceScreenState();
}

class _EditMyPriceScreenState extends State<EditMyPriceScreen> {
  late final EditMyPriceController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(EditMyPriceController());
    controller.initPage(context: context, set: setState);
  }

  @override
  void dispose() {
    Get.delete<EditMyPriceController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final overview = controller.overview;
    final entry = controller.entry;
    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
              child: Column(
            children: [
              appBarBack(
                l.editCombination,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    const SizedBox(height: 8),
                    _readOnly(
                        l.productLabel, overview.productName(entry), true),
                    _readOnly(l.region, overview.regionName(entry), true),
                    _readOnly(l.paymentForm, overview.paymentName(entry), true),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.enterPricePerTon,
                                style: AppFonts.body2medium.white),
                            const SizedBox(height: 6),
                            TextFieldWidget(
                              textStyle: AppFonts.body2medium.white,
                              controller: controller.priceController,
                              height: 56,
                              colorBg: AppColors.backgroundGradient1,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              border:
                                  Border.all(color: AppColors.myPriceCardBg),
                              padding: EdgeInsets.zero,
                            )
                          ]),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final selected = await showMyPricePicker(
                          context: context,
                          title: l.teamNumber,
                          items: overview.team,
                          label: (item) => item.label,
                        );
                        if (selected != null) {
                          setState(() => controller.teamUserId = selected.id);
                        }
                      },
                      child: _readOnly(
                          l.teamNumber,
                          overview.team
                              .firstWhere(
                                (e) => e.id == controller.teamUserId,
                                orElse: () => const MyPriceTeamMember(),
                              )
                              .label,
                          false),
                    ),
                    const SizedBox(height: 24),
                    bStyle(
                      text: l.saveChanges,
                      c: context,
                      vertical: 12,
                      onPressed: controller.onSave,
                    ),
                  ],
                ),
              )
            ],
          )),
        ],
      ),
    );
  }

  Widget _readOnly(String label, String value, bool isOnlyRead) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.body2medium.white),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.backgroundGradient1,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.myPriceCardBg, width: 1.5),
            ),
            child: Text(value,
                style: isOnlyRead
                    ? AppFonts.body2medium.grey3
                    : AppFonts.body2medium.white),
          ),
        ],
      ),
    );
  }
}
