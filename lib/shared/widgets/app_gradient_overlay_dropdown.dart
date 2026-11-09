import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/custom_tap.dart';
import 'package:flutter/material.dart';

/// Single option for [AppGradientOverlayDropdown].
class GradientDropdownItem<T> {
  const GradientDropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}

/// Wallet-style dropdown: gradient trigger, animated overlay menu with brand border.
class AppGradientOverlayDropdown<T> extends StatefulWidget {
  const AppGradientOverlayDropdown({
    super.key,
    required this.items,
    required this.onSelected,
    this.selected,
    this.placeholder,
    this.expandTriggerWidth = false,
    this.overlayVerticalOffset = 45,
    this.enabled = true,
    this.triggerBorderWidth = 1.5,
    this.triggerCornerRadius = 16,
    this.triggerPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.triggerPlain = false,
    this.triggerTextStyle,
  });

  final T? selected;
  final List<GradientDropdownItem<T>> items;
  final ValueChanged<T> onSelected;
  final String? placeholder;
  final bool expandTriggerWidth;
  final double overlayVerticalOffset;
  final bool enabled;

  /// [AppGradientBox] stroke width for the trigger pill (wallet default 1.5).
  final double triggerBorderWidth;

  /// Corner radius for the trigger pill (wallet default 16; [AppTextField] uses 20).
  final double triggerCornerRadius;

  /// Inner padding of the trigger pill (wallet default 12×10; text fields use 16×14).
  final EdgeInsetsGeometry triggerPadding;

  /// Matches [AppTextField] light-mode plain white pill when true.
  final bool triggerPlain;

  /// When set, used for trigger label text; otherwise wallet compact [bodySmall] 12px.
  final TextStyle? triggerTextStyle;

  @override
  State<AppGradientOverlayDropdown<T>> createState() =>
      _AppGradientOverlayDropdownState<T>();
}

class _AppGradientOverlayDropdownState<T>
    extends State<AppGradientOverlayDropdown<T>> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  double _buttonWidth = 0;

  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotation;

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _rotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_isOpen) {
      _overlayEntry?.remove();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppGradientOverlayDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected && _isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _overlayEntry?.markNeedsBuild();
      });
    }
  }

  void _toggle() {
    if (!widget.enabled || widget.items.isEmpty) return;
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    setState(() => _isOpen = true);
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward();
  }

  void _close() {
    _controller.reverse().then((_) {
      if (!mounted) return;
      setState(() => _isOpen = false);
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  String _selectedLabel() {
    for (final item in widget.items) {
      if (item.value == widget.selected) return item.label;
    }
    return widget.placeholder ?? '';
  }

  OverlayEntry _createOverlayEntry() {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.appColors;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            width: _buttonWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, widget.overlayVerticalOffset),
              child: Material(
                color: Colors.transparent,
                child: SizeTransition(
                  sizeFactor: _expandAnimation,
                  axisAlignment: -1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: colors.brand.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.items.map((item) {
                          final isSelected = item.value == widget.selected;
                          return InkWell(
                            onTap: () {
                              widget.onSelected(item.value);
                              _close();
                            },
                            child: Container(
                              width: _buttonWidth,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.p16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.brand.withOpacity(0.08)
                                    : Colors.transparent,
                              ),
                              child: Text(
                                item.label,
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? colors.brand
                                      : colors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _computeIntrinsicWidth(TextStyle? style) {
    final painter = TextPainter(textDirection: TextDirection.ltr);
    double maxW = 0;
    for (final item in widget.items) {
      painter.text = TextSpan(text: item.label, style: style);
      painter.layout();
      if (painter.width > maxW) maxW = painter.width;
    }
    if (widget.placeholder != null) {
      painter.text = TextSpan(text: widget.placeholder, style: style);
      painter.layout();
      if (painter.width > maxW) maxW = painter.width;
    }
    final hPad = widget.triggerPadding.horizontal;
    return maxW + hPad + 28;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.appColors;
    final labelStyle = widget.triggerTextStyle ??
        textTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        );
    final displayLabel = _selectedLabel();
    final showPlaceholder =
        widget.selected == null &&
        widget.placeholder != null &&
        displayLabel == widget.placeholder;

    TextStyle resolvedLabelStyle({required bool placeholder}) {
      if (widget.triggerTextStyle != null) {
        final t = widget.triggerTextStyle!;
        return t.copyWith(
          color: placeholder
              ? colors.textSecondary
              : (t.color ?? colors.textPrimary),
        );
      }
      return textTheme.bodySmall!.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: placeholder ? colors.textSecondary : colors.textPrimary,
      );
    }

    final hPad = widget.triggerPadding.horizontal;
    Widget buildTrigger(double width) {
      _buttonWidth = width;
      final innerMaxWidth = (width - hPad).clamp(0.0, double.infinity);
      return CompositedTransformTarget(
        link: _layerLink,
        child: CustomTap(
          onTap: _toggle,
          radius: widget.triggerCornerRadius,
          child: AppGradientBox(
            isPlain: widget.triggerPlain,
            borderWidth: widget.triggerBorderWidth,
            cornerRadius: widget.triggerCornerRadius,
            padding: widget.triggerPadding,
            child: SizedBox(
              width: widget.expandTriggerWidth ? null : innerMaxWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize:
                    widget.expandTriggerWidth ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (widget.expandTriggerWidth)
                    Expanded(
                      child: Text(
                        displayLabel.isEmpty ? ' ' : displayLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: resolvedLabelStyle(placeholder: showPlaceholder),
                      ),
                    )
                  else
                    Text(
                      displayLabel.isEmpty ? ' ' : displayLabel,
                      style: resolvedLabelStyle(placeholder: showPlaceholder),
                    ),
                  RotationTransition(
                    turns: _rotation,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (widget.expandTriggerWidth) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 200.0;
          return SizedBox(width: w, child: buildTrigger(w));
        },
      );
    }

    _buttonWidth = _computeIntrinsicWidth(labelStyle);
    return buildTrigger(_buttonWidth);
  }
}
