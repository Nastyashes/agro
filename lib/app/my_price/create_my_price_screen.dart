import 'package:agro/app/my_price/components/my_price_dialogs.dart';
import 'package:agro/app/my_price/components/my_price_ui.dart';
import 'package:agro/app/my_price/controller/create_my_price_controller.dart';
import 'package:agro/model/my_price/my_price_models.dart';
import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/components/app_top_bar.dart';
import 'package:agro/ui/components/form_tile.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
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
  bool _showPromo = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CreateMyPriceController());
    controller.ui =
        ScreenMyPriceUi(context, mainController: controller.mainController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.ensureOverview();
    });
  }

  @override
  void dispose() {
    Get.delete<CreateMyPriceController>();
    super.dispose();
  }

  String? _name(List<MyPriceNamedItem> items, int? id) {
    if (id == null) return null;
    final name = controller.overview.value.nameOf(items, id);
    return name == '—' ? null : name;
  }

  Future<void> _pick<T>(
    String title,
    List<T> items,
    String Function(T) label,
    void Function(T) onSelected, {
    bool search = false,
  }) async {
    final selected = await showMyPricePicker<T>(
      context: context,
      title: title,
      items: items,
      label: label,
      enableSearch: search,
    );
    if (selected != null) onSelected(selected);
  }

  List<String> _missing(BuildContext context) {
    final l = context.l;
    return missingComboFields(
      product: controller.productId.value,
      region: controller.regionId.value,
      payment: controller.paymentType.value,
      price: controller.priceController.text,
      team: controller.teamUserId.value,
      labels: (
        product: l.crop,
        region: l.region,
        payment: l.paymentForm,
        price: l.pricePerTonLabel,
        team: l.contactPerson,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      backgroundColor: Palette.bg0,
      bottomNavigationBar: _bottomBar(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(title: l.newCombination),
            Expanded(
              child: Obx(() {
                final o = controller.overview.value;
                final errors = controller.fieldErrors;
                final team = controller.teamUserId.value == null
                    ? null
                    : o.team
                        .firstWhere(
                          (e) => e.id == controller.teamUserId.value,
                          orElse: () => const MyPriceTeamMember(),
                        )
                        .label;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Text(l.combinationIntro, style: AppText.title),
                    const SizedBox(height: 16),
                    SelectTile(
                      icon: Icons.grass_rounded,
                      label: l.crop,
                      value: _name(o.products, controller.productId.value),
                      placeholder: l.selectCrop,
                      error: errors['product_id'] != null,
                      onTap: () => _pick(
                          l.selectCrop,
                          o.products,
                          (MyPriceNamedItem e) => e.name,
                          (e) => controller.productId.value = e.id,
                          search: true),
                    ),
                    const SizedBox(height: 10),
                    SelectTile(
                      icon: Icons.location_on_outlined,
                      label: l.region,
                      value: _name(o.regions, controller.regionId.value),
                      placeholder: l.selectRegion,
                      error: errors['region_id'] != null,
                      onTap: () => _pick(
                          l.selectRegion,
                          o.regions,
                          (MyPriceNamedItem e) => e.name,
                          (e) => controller.regionId.value = e.id),
                    ),
                    const SizedBox(height: 10),
                    SelectTile(
                      icon: Icons.payments_outlined,
                      label: l.paymentForm,
                      value:
                          _name(o.paymentTypes, controller.paymentType.value),
                      placeholder: l.paymentForm,
                      error: errors['payment_type'] != null,
                      onTap: () => _pick(
                          l.paymentForm,
                          o.paymentTypes,
                          (MyPriceNamedItem e) => e.name,
                          (e) => controller.paymentType.value = e.id),
                    ),
                    const SizedBox(height: 10),
                    InputTile(
                      icon: Icons.sell_outlined,
                      label: l.pricePerTonLabel,
                      hint: l.enterPricePerTon,
                      controller: controller.priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      suffix: '${l.uahShort} / ${l.tonShort}',
                      big: true,
                      error: errors['price_per_ton'] != null,
                    ),
                    const SizedBox(height: 10),
                    SelectTile(
                      icon: Icons.person_outline_rounded,
                      label: l.contactPerson,
                      value: team,
                      placeholder: l.teamNumber,
                      error: errors['team_user_id'] != null,
                      onTap: () => _pick(
                          l.teamNumber,
                          o.team,
                          (MyPriceTeamMember e) => e.label,
                          (e) => controller.teamUserId.value = e.id),
                    ),
                    const SizedBox(height: 10),
                    if (_showPromo ||
                        controller.promoController.text.isNotEmpty)
                      InputTile(
                        icon: Icons.confirmation_number_outlined,
                        label: l.promoCodeOptional,
                        controller: controller.promoController,
                        autofocus: _showPromo,
                      )
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _showPromo = true),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: Text(l.havePromo),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    final l = context.l;
    return Container(
      decoration: const BoxDecoration(
        color: Palette.bg0,
        border: Border(top: BorderSide(color: Palette.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ValueListenableBuilder(
              valueListenable: controller.priceController,
              builder: (context, _, __) => Obx(() {
                final missing = _missing(context);
                if (missing.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: Palette.textTertiary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l.remainingFields(missing.join(', ').toLowerCase()),
                          style: AppText.caption
                              .copyWith(color: Palette.textTertiary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            AppButton(
              label: l.saveCombination,
              onPressed: controller.onSubmit,
            ),
          ]),
        ),
      ),
    );
  }
}

/// Labels of the required combination fields that are still empty, in form
/// order; drives the "Залишилось: …" hint.
List<String> missingComboFields({
  required int? product,
  required int? region,
  required int? payment,
  required String price,
  required int? team,
  required ({
    String product,
    String region,
    String payment,
    String price,
    String team,
  }) labels,
}) =>
    [
      if (product == null) labels.product,
      if (region == null) labels.region,
      if (payment == null) labels.payment,
      if (price.trim().isEmpty) labels.price,
      if (team == null) labels.team,
    ];
