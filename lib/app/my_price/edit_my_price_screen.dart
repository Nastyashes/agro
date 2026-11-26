import 'package:agro/app/my_price/components/my_price_dialogs.dart';
import 'package:agro/app/my_price/components/my_price_ui.dart';
import 'package:agro/app/my_price/controller/edit_my_price_controller.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/components/app_top_bar.dart';
import 'package:agro/ui/components/form_tile.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    controller.ui =
        ScreenMyPriceUi(context, mainController: controller.mainController);
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
      backgroundColor: Palette.bg0,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Palette.bg0,
          border: Border(top: BorderSide(color: Palette.line)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child:
                AppButton(label: l.saveChanges, onPressed: controller.onSave),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(title: l.editCombination),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  // Product, region and payment cannot change after creation.
                  SelectTile(
                    icon: Icons.grass_rounded,
                    label: l.crop,
                    value: overview.productName(entry),
                    placeholder: '—',
                    onTap: null,
                  ),
                  const SizedBox(height: 10),
                  SelectTile(
                    icon: Icons.location_on_outlined,
                    label: l.region,
                    value: overview.regionName(entry),
                    placeholder: '—',
                    onTap: null,
                  ),
                  const SizedBox(height: 10),
                  SelectTile(
                    icon: Icons.payments_outlined,
                    label: l.paymentForm,
                    value: overview.paymentName(entry),
                    placeholder: '—',
                    onTap: null,
                  ),
                  const SizedBox(height: 10),
                  Obx(() => InputTile(
                        error: controller.priceError.value,
                        icon: Icons.sell_outlined,
                        label: l.pricePerTonLabel,
                        controller: controller.priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        suffix: '${l.uahShort} / ${l.tonShort}',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                          LengthLimitingTextInputFormatter(12),
                        ],
                        big: true,
                      )),
                  const SizedBox(height: 10),
                  Obx(() => SelectTile(
                        icon: Icons.person_outline_rounded,
                        label: l.contactPerson,
                        value: overview.team
                            .firstWhere(
                              (e) => e.id == controller.teamUserId.value,
                              orElse: () => const MyPriceTeamMember(),
                            )
                            .label,
                        placeholder: l.teamNumber,
                        onTap: () async {
                          final selected = await showMyPricePicker(
                            context: context,
                            title: l.teamNumber,
                            items: overview.team,
                            label: (item) => item.label,
                          );
                          if (selected != null) {
                            controller.teamUserId.value = selected.id;
                          }
                        },
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
