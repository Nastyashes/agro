import 'package:agro/ui/theme/colors.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

Future<bool> showMyPriceConfirmDialog({
  required BuildContext context,
  required String title,
  required String body,
  String? confirmText,
  bool confirmEnabled = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.grey1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppFonts.body1bold.black, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(body, style: AppFonts.body3medium.black, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(context.l.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGreen,
                        disabledBackgroundColor:
                            AppColors.mainGreen.withValues(alpha: 0.3),
                      ),
                      onPressed: confirmEnabled
                          ? () => Navigator.pop(dialogContext, true)
                          : null,
                      child: Text(
                        confirmText ?? context.l.confirm,
                        style: AppFonts.body2bold.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
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
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (sheetContext) {
      var query = '';

      return StatefulBuilder(
        builder: (context, setState) {
          final mediaQuery = MediaQuery.of(sheetContext);

          final keyboardHeight = mediaQuery.viewInsets.bottom;
          final screenHeight = mediaQuery.size.height;
          final topSafeArea = mediaQuery.padding.top;

          // Максимальна висота sheet без клавіатури.
          final defaultMaxHeight = screenHeight * 0.8;

          // Реально доступне місце при відкритій клавіатурі.
          final availableHeight =
              screenHeight - keyboardHeight - topSafeArea;

          // Sheet не повинен бути вищим за доступну область.
          final maxSheetHeight = defaultMaxHeight < availableHeight
              ? defaultMaxHeight
              : availableHeight;

          final filtered = enableSearch && query.trim().isNotEmpty
              ? items
                  .where(
                    (item) => label(item)
                        .toLowerCase()
                        .contains(query.trim().toLowerCase()),
                  )
                  .toList()
              : items;

          return Padding(
            padding: EdgeInsets.only(
              bottom: keyboardHeight,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxSheetHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),

                  Container(
                    height: 4,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.grey2,
                      borderRadius: BorderRadius.circular(60),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      16,
                    ),
                    child: Text(
                      title,
                      style: AppFonts.body1bold.black,
                    ),
                  ),

                  if (enableSearch)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        8,
                      ),
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: context.l.search,
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppColors.grey1,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => query = value);
                        },
                      ),
                    ),

                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: AppColors.grey2,
                      ),
                      itemBuilder: (_, index) {
                        final item = filtered[index];

                        return ListTile(
                          leading: const Icon(
                            Icons.circle_outlined,
                          ),
                          title: Text(
                            label(item),
                            style: AppFonts.body2medium.black,
                          ),
                          onTap: () {
                            Navigator.pop(
                              sheetContext,
                              item,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}