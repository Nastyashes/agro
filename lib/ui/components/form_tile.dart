import 'package:agro/ui/theme/app_text.dart';
import 'package:agro/ui/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

BoxDecoration _box({required bool error, bool focus = false}) => BoxDecoration(
      color: Palette.bg1,
      borderRadius: BorderRadius.circular(Radii.button),
      border: Border.all(
        color: error
            ? Palette.red
            : focus
                ? Palette.green
                : Palette.line,
        width: error || focus ? 1.5 : 1,
      ),
    );

/// Tappable form field that opens a picker: icon, small label, value or
/// placeholder, chevron. With [onTap] null it is read-only.
class SelectTile extends StatelessWidget {
  const SelectTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.error = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback? onTap;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final filled = value != null && value!.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.button),
        child: Ink(
          decoration: _box(error: error),
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Row(children: [
            Icon(icon,
                size: 22, color: filled ? Palette.green : Palette.textTertiary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppText.caption
                          .copyWith(color: Palette.textTertiary)),
                  const SizedBox(height: 2),
                  Text(filled ? value! : placeholder,
                      style: AppText.bodyMedium.copyWith(
                          color: filled
                              ? (onTap == null
                                  ? Palette.textSecondary
                                  : Palette.textPrimary)
                              : Palette.textTertiary)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.expand_more_rounded,
                  size: 22, color: Palette.textTertiary),
          ]),
        ),
      ),
    );
  }
}

/// Text input in the same shape as [SelectTile]; [big] uses the number
/// style (prices), [suffix] sits on the right (e.g. "₴ / т").
class InputTile extends StatefulWidget {
  const InputTile({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    this.hint,
    this.suffix,
    this.keyboardType,
    this.big = false,
    this.error = false,
    this.autofocus = false,
    this.inputFormatters,
  });

  final List<TextInputFormatter>? inputFormatters;
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? suffix;
  final TextInputType? keyboardType;
  final bool big;
  final bool error;
  final bool autofocus;

  @override
  State<InputTile> createState() => _InputTileState();
}

class _InputTileState extends State<InputTile> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _focus.requestFocus,
      child: Container(
        decoration: _box(error: widget.error, focus: _focus.hasFocus),
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Row(children: [
          Icon(widget.icon,
              size: 22,
              color: _focus.hasFocus || widget.controller.text.isNotEmpty
                  ? Palette.green
                  : Palette.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label,
                    style:
                        AppText.caption.copyWith(color: Palette.textTertiary)),
                TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  style: widget.big ? AppText.numL : AppText.bodyMedium,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(top: 2),
                    hintText: widget.hint,
                  ),
                ),
              ],
            ),
          ),
          if (widget.suffix != null)
            Text(widget.suffix!,
                style:
                    AppText.bodyMedium.copyWith(color: Palette.textSecondary)),
        ]),
      ),
    );
  }
}
