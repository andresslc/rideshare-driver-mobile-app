import 'dart:ui';

import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/extensions/theme_extension.dart';

class DraggableSheetWidget extends StatefulWidget {
  final String title;
  final String buttonText;
  final Widget? child;
  final bool isButtonAvailable;
  final double heightFactor;
  final bool sizeToChild;
  final EdgeInsetsGeometry? padding;
  final Function()? onSubmit;
  final List<FocusNode>? expandOnFocusNodes;

  const DraggableSheetWidget({
    super.key,
    this.title = '',
    this.child,
    this.onSubmit,
    this.buttonText = '',
    this.isButtonAvailable = true,
    this.heightFactor = 0.7,
    this.sizeToChild = false,
    this.padding,
    this.expandOnFocusNodes,
  });

  @override
  State<DraggableSheetWidget> createState() => _DraggableSheetWidgetState();
}

class _DraggableSheetWidgetState extends State<DraggableSheetWidget> {
  double _sheetHeightFactor = 0.7;
  final double _maxFactor = 0.95;

  double get _minFactor => widget.sizeToChild ? 0.0 : 0.6;

  @override
  void initState() {
    super.initState();
    _sheetHeightFactor = widget.heightFactor;
    _setupFocusListeners();
  }

  void _setupFocusListeners() {
    if (widget.expandOnFocusNodes != null) {
      for (final node in widget.expandOnFocusNodes!) {
        node.addListener(_handleFocusChange);
      }
    }
  }

  void _removeFocusListeners() {
    if (widget.expandOnFocusNodes != null) {
      for (final node in widget.expandOnFocusNodes!) {
        node.removeListener(_handleFocusChange);
      }
    }
  }

  void _handleFocusChange() {
    final anyFocused = widget.expandOnFocusNodes!.any((node) => node.hasFocus);
    if (anyFocused && _sheetHeightFactor < _maxFactor) {
      setState(() {
        _sheetHeightFactor = _maxFactor;
      });
    }
  }

  @override
  void didUpdateWidget(covariant DraggableSheetWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.heightFactor != widget.heightFactor) {
      setState(() {
        _sheetHeightFactor = widget.heightFactor;
      });
    }
    if (oldWidget.expandOnFocusNodes != widget.expandOnFocusNodes) {
      _removeFocusListeners();
      _setupFocusListeners();
    }
  }

  @override
  void dispose() {
    _removeFocusListeners();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _sheetHeightFactor -=
          details.primaryDelta! / MediaQuery.of(context).size.height;
      _sheetHeightFactor = _sheetHeightFactor.clamp(_minFactor, _maxFactor);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final double midPoint = (_minFactor + _maxFactor) / 2;
    if (_sheetHeightFactor <= _minFactor + 0.02) {
      context.pop();
    } else {
      setState(() {
        if (widget.sizeToChild) {
          _sheetHeightFactor = widget.heightFactor;
        } else if (_sheetHeightFactor < midPoint) {
          _sheetHeightFactor = _minFactor;
        } else {
          _sheetHeightFactor = _maxFactor;
        }
      });
    }
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final sheet = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: Stack(
        children: [
          if (context.colorScheme.brightness == Brightness.dark) ...[
            Positioned.fill(
              child: Image.asset(
                AppImages.bgBottom,
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Colors.white.withOpacity(0.05)),
              ),
            ),
          ],
          Focus(
            onFocusChange: (hasFocus) {
              if (widget.expandOnFocusNodes == null &&
                  hasFocus &&
                  _sheetHeightFactor < _maxFactor) {
                setState(() {
                  _sheetHeightFactor = _maxFactor;
                });
              }
            },
            child: Container(
              color: context.colorScheme.brightness == Brightness.dark
                  ? Colors.transparent
                  : Colors.white,
              padding:
                  widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisSize: widget.sizeToChild
                    ? MainAxisSize.min
                    : MainAxisSize.max,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: _onDragUpdate,
                    onVerticalDragEnd: _onDragEnd,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(top: 8, bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        if (widget.title.isNotEmpty)
                          Center(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  if (widget.child != null)
                    if (widget.sizeToChild)
                      Flexible(
                        fit: FlexFit.loose,
                        child: widget.child!,
                      )
                    else
                      Expanded(child: widget.child!),
                  const SizedBox(height: 16),
                  if (widget.isButtonAvailable)
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: widget.buttonText,
                        onPressed: widget.onSubmit,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: widget.sizeToChild
          ? Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.sizeOf(context).height * _sheetHeightFactor,
                  ),
                  child: sheet,
                ),
              ),
            )
          : FractionallySizedBox(
              heightFactor: _sheetHeightFactor,
              child: sheet,
            ),
    );
  }
}
