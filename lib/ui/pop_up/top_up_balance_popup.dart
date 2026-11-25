import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Smallest top-up the payment provider accepts, in UAH.
const int minTopUpAmount = 10;
const List<int> topUpPresets = [100, 200, 500, 1000];

/// Top-up bottom sheet. [onSelect] runs once, with a valid amount, after
/// the sheet is closed; closing it any other way does nothing.
void showTopUpDialog(BuildContext context, int? balance,
    final void Function(int amount) onSelect) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => TopUpSheet(balance: balance, onSelect: onSelect),
  );
}

class TopUpSheet extends StatefulWidget {
  const TopUpSheet({super.key, required this.balance, required this.onSelect});

  final int? balance;
  final void Function(int amount) onSelect;

  @override
  State<TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<TopUpSheet> {
  final _input = TextEditingController();
  int _amount = 200;
  bool _invalid = false;
  bool _paid = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _pick(int amount) => setState(() {
        _amount = amount;
        _invalid = false;
        _input.clear();
      });

  void _pay() {
    if (_paid) return;
    if (_amount < minTopUpAmount) {
      setState(() => _invalid = true);
      return;
    }
    _paid = true;
    Navigator.of(context).pop();
    widget.onSelect(_amount);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.topUpTitle, style: AppText.title),
                  Text(l.balanceNow,
                      style: AppText.caption
                          .copyWith(color: Palette.textTertiary)),
                ],
              ),
            ),
            Text(context.uahAmount(widget.balance ?? 0),
                style: AppText.numL.copyWith(color: Palette.textSecondary)),
          ]),
          const SizedBox(height: 18),
          Center(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '$_amount', style: AppText.numXL),
              TextSpan(
                  text: ' ${l.uahShort}',
                  style: AppText.title.copyWith(color: Palette.textSecondary)),
            ])),
          ),
          const SizedBox(height: 18),
          Row(children: [
            for (final a in topUpPresets) ...[
              if (a != topUpPresets.first) const SizedBox(width: 8),
              Expanded(
                child: _Preset(
                  amount: a,
                  selected: _amount == a && _input.text.isEmpty,
                  onTap: () => _pick(a),
                ),
              ),
            ],
          ]),
          const SizedBox(height: 14),
          TextField(
            controller: _input,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: AppText.bodyMedium,
            decoration: InputDecoration(
              hintText: l.orInputSum,
              errorText: _invalid ? l.errorPaymant : null,
            ),
            onChanged: (v) => setState(() {
              _amount = int.tryParse(v) ?? 0;
              _invalid = false;
            }),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: l.payAmount(context.uahAmount(_amount)),
            onPressed: _pay,
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.lock_outline_rounded,
                size: 14, color: Palette.textTertiary),
            const SizedBox(width: 6),
            Text(l.securePayment,
                style: AppText.caption.copyWith(color: Palette.textTertiary)),
          ]),
        ],
      ),
    );
  }
}

class _Preset extends StatelessWidget {
  const _Preset(
      {required this.amount, required this.selected, required this.onTap});

  final int amount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? Palette.textPrimary : Palette.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: selected
              ? BorderSide.none
              : const BorderSide(color: Palette.line),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text('$amount',
                  style: AppText.num.copyWith(
                      color: selected
                          ? Palette.textInverse
                          : Palette.textPrimary)),
            ),
          ),
        ),
      );
}
