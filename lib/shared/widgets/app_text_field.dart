import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/extensions/theme_extension.dart';
import 'app_gradient_box.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.prefixIcon,
    this.hintMaxLines,
    this.hintStyle,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.errorText,
    this.helperText,
    this.hintOverflow,

    this.enabled = true,
    this.isGreishText = false,
    this.maxLength = 45,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.readOnly = false,
    this.autoFocus = false,
    this.focusNode,
    this.maxlines,
    this.isPlain = false,
    this.radius,
  });
  final int? maxlines;
  final num? radius;
  final bool isPlain;
  final TextStyle? hintStyle;

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final String? labelText;
  final TextOverflow? hintOverflow;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String? errorText;
  final int? hintMaxLines;

  final String? helperText;
  final bool enabled;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final bool autoFocus;
  final bool istouched = false;
  final bool isGreishText;

  TextStyle? _resolvedHintStyle(BuildContext context) {
    final themeHintStyle = Theme.of(context).inputDecorationTheme.hintStyle;
    final baseStyle = hintStyle ?? themeHintStyle;
    if (hintOverflow == null) return baseStyle;
    return (baseStyle ?? const TextStyle()).copyWith(overflow: hintOverflow);
  }

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;
  final _fieldKey = GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    final state = _fieldKey.currentState;
    if (mounted && state != null && state.mounted) {
      state.didChange(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    const borderWidth = 1.0;
    final num cornerRadius = widget.radius ?? 20;

    return FormField<String>(
      key: _fieldKey,
      initialValue: widget.controller.text,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Label
            if (widget.labelText != null && widget.labelText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  widget.labelText!,
                  style: context.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),

            AppGradientBox(
              isPlain: context.theme.brightness == Brightness.light,
              borderWidth: borderWidth,
              cornerRadius: cornerRadius.toDouble(),
              child: TextFormField(
                autofocus: widget.autoFocus,

                focusNode: widget.focusNode,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                maxLines: widget.maxlines,
                obscureText: _obscure,
                // validator: widget.validator,
                onChanged: (value) {
                  state.didChange(value);
                  widget.onChanged?.call(value);
                },
                onTap: widget.onTap,
                enabled: widget.enabled,

                maxLength: widget.maxLength,
                autofillHints: widget.autofillHints,
                textCapitalization: widget.textCapitalization,
                inputFormatters: widget.inputFormatters,
                readOnly: widget.readOnly,
                style: !widget.enabled && widget.isGreishText
                    ? context.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.withValues(alpha: .6),
                      )
                    : context.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: widget._resolvedHintStyle(context),

                  hintMaxLines: widget.hintMaxLines,

                  // if enabled is false, use a lighter hint color
                  // hintStyle: !widget.enabled
                  //     ? context.textTheme.bodyLarge?.copyWith(
                  //         color: Colors.grey.withBlue(0.6),
                  //       )
                  //     : null,
                  // labelText: widget.labelText,
                  errorText: widget.errorText,
                  // helperText: widget.helperText,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      cornerRadius.toDouble(),
                    ),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  prefixIcon: widget.prefixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ImageIcon(
                            AssetImage(widget.prefixIcon!),
                            size: 16,
                          ),
                        )
                      : null,

                  prefixIconConstraints: const BoxConstraints(
                    minHeight: 0,
                    minWidth: 0,
                  ),
                  suffixIcon: widget.obscureText
                      ? IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        )
                      : widget.suffixIcon,
                ),
              ),
            ),

            if (state.errorText == null && widget.helperText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Text(
                  widget.helperText!,
                  style: context.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.appColors.brand,
                    fontSize: 11,
                  ),
                ),
              ),
            // if (state.errorText != null && (state.value?.isNotEmpty ?? false))
            if (state.errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
