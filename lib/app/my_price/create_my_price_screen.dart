import 'package:agro/app/my_price/components/my_price_dialogs.dart';
import 'package:agro/app/my_price/controller/create_my_price_controller.dart';
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

class CreateMyPriceScreen extends StatefulWidget {
  const CreateMyPriceScreen({super.key});

  @override
  State<CreateMyPriceScreen> createState() => _CreateMyPriceScreenState();
}

class _CreateMyPriceScreenState extends State<CreateMyPriceScreen> {
  late final CreateMyPriceController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CreateMyPriceController());
    controller.initPage(context: context, set: setState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.ensureOverview();
    });
  }

  @override
  void dispose() {
    Get.delete<CreateMyPriceController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;

    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: Column(
              children: [
                  appBarBack( l.createCombinationTitle),
        
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    children: [
                      _selectField(
                        l.selectCrop,
                        controller.overview.nameOf(
                                  controller.overview.products,
                                  controller.productId,
                                ) ==
                                '—'
                            ? ''
                            : controller.overview.nameOf(
                                controller.overview.products,
                                controller.productId,
                              ),
                        () async {
                          final selected = await showMyPricePicker(
                            context: context,
                            title: l.selectCrop,
                            items: controller.overview.products,
                            label: (item) => item.name,
                            enableSearch: true,
                          );
                          if (selected != null) {
                            setState(() => controller.productId = selected.id);
                          }
                        },
                        error: controller.fieldErrors['product_id'] != null,
                      ),
                      _selectField(
                         l.selectRegion,
                        controller.overview.nameOf(
                                  controller.overview.regions,
                                  controller.regionId,
                                ) ==
                                '—'
                            ? ''
                            : controller.overview.nameOf(
                                controller.overview.regions,
                                controller.regionId,
                              ),
                        () async {
                          final selected = await showMyPricePicker(
                            context: context,
                            title: l.selectRegion,
                            items: controller.overview.regions,
                            label: (item) => item.name,
                          );
                          if (selected != null) {
                            setState(() => controller.regionId = selected.id);
                          }
                        },
                        error: controller.fieldErrors['region_id'] != null,
                      ),
                  
                      _selectField(
                        l.paymentForm,
                        controller.paymentType == null
                            ? ''
                            : 
                            controller.overview.nameOf(
                                controller.overview.paymentTypes,
                                controller.paymentType,
                              ),
                        () async {
                          final selected = await showMyPricePicker(
                            context: context,
                            title: l.paymentForm,
                            items: controller.overview.paymentTypes,
                            label: (item) => item.name,
                          );
                          if (selected != null) {
                            setState(
                                () => controller.paymentType = selected.id);
                          }
                        },
                        error: controller.fieldErrors['payment_type'] != null,
                      ),
                          _selectField(
                        l.enterPricePerTon,
                        null,
                        null,
                        controller: controller.priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        error: controller.fieldErrors['price_per_ton'] != null,
                      ),
                      _selectField(
                      l.contactPerson,
                        controller.teamUserId == null
                           ? ''
                           : 
                            controller.overview.team
                                .firstWhere(
                                  (e) => e.id == controller.teamUserId,
                                  orElse: () => const MyPriceTeamMember(),
                                )
                                .label,
                        () async {
                          final selected = await showMyPricePicker(
                            context: context,
                            title: l.teamNumber,
                            items: controller.overview.team,
                            label: (item) => item.label,
                          );
                          if (selected != null) {
                            setState(() => controller.teamUserId = selected.id);
                          }
                        },
                        error: controller.fieldErrors['team_user_id'] != null,
                      ),
                      _selectField(
                        l.promoCodeOptional,
                        null,
                        null,
                        controller: controller.promoController,
                      ),
                      const SizedBox(height: 20),
                      bStyle(
                        text: l.confirm,
                        c: context,
                        vertical: 16,
                        onPressed: controller.onSubmit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectField(
    String hint,
    String? value,
    VoidCallback? onTap, {
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool error = false,
  }) {
    final border = Border.all(
      color: error ? AppColors.red : AppColors.additionalGreen,
    );
    if (controller != null) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(hint, style: AppFonts.body2medium.black),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextFieldWidget(
                controller: controller,
                text: value ?? hint,
                height: 56,
                hintStyle: AppFonts.body2medium.grey3,
                colorBg: AppColors.white,
                border: border,
                borderRadius: BorderRadius.circular(28),
                keyboardType: keyboardType,
                padding: EdgeInsets.zero,
              ),
            )
          ]);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(hint, style: AppFonts.body2medium.black),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 56,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
                border: border,
              ),
              child: Text((value != null && value.isNotEmpty) ?value : hint,
                  style: (value != null && value.isNotEmpty)
                      ? AppFonts.body2medium.black
                      : AppFonts.body2medium.grey3),
            ),
          ),
        ),
      ],
    );
  }
}
