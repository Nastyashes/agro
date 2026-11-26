import 'package:agro/ui/components/app_button.dart';
import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

/// Confirm a paid My price action. With [confirmEnabled] false the confirm
/// button is disabled (e.g. not enough balance), so it can only be closed.
Future<bool> showMyPriceConfirmDialog({
  required BuildContext context,
  required String title,
  required String body,
  String? confirmText,
  bool confirmEnabled = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                    color: Palette.greenSoft, shape: BoxShape.circle),
                child: const Icon(Icons.handshake_outlined,
                    size: 26, color: Palette.green),
              ),
              const SizedBox(height: 14),
              Text(title, style: AppText.title, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(body,
                  style: AppText.body.copyWith(color: Palette.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                  child: AppButton(
                    label: context.l.cancel,
                    style: AppButtonStyle.secondary,
                    onPressed: () => Navigator.pop(dialogContext, false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: confirmText ?? context.l.confirm,
                    onPressed: confirmEnabled
                        ? () => Navigator.pop(dialogContext, true)
                        : null,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    ),
  );
  return result == true;
}

Future<T?> showMyPricePicker<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T item) label,
  bool enableSearch = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _PickerSheet<T>(
      title: title,
      items: items,
      label: label,
      enableSearch: enableSearch,
    ),
  );
}

/// List picker with optional search. The query lives in this State, so
/// hiding the keyboard (which rebuilds the sheet) keeps the filter.
class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.items,
    required this.label,
    required this.enableSearch,
  });

  final String title;
  final List<T> items;
  final String Function(T item) label;
  final bool enableSearch;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final available =
        mediaQuery.size.height - keyboardHeight - mediaQuery.padding.top;
    final maxSheetHeight = (mediaQuery.size.height * 0.8).clamp(0.0, available);

    final query = _search.text.trim().toLowerCase();
    final filtered = widget.enableSearch && query.isNotEmpty
        ? widget.items
            .where((item) => widget.label(item).toLowerCase().contains(query))
            .toList()
        : widget.items;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(widget.title, style: AppText.headline),
            ),
            if (widget.enableSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _search,
                  autofocus: true,
                  style: AppText.bodyMedium,
                  decoration: InputDecoration(
                    hintText: context.l.search,
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Palette.textSecondary),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final item = filtered[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(widget.label(item), style: AppText.bodyMedium),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: Palette.textTertiary),
                    onTap: () => Navigator.pop(context, item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
