import 'package:driver_app/core/core.dart';
import 'package:flutter/material.dart';

/// A premium, animated neon-glow CTA button for opening Google Maps navigation.
///
/// Features:
/// 1. A localized text recommendation centered directly above the button.
/// 2. An animated, rotating SweepGradient border using CustomPainter.
/// 3. A 3-layered glowing BoxShadow breathing effect.
/// 4. A slow, subtle horizontal shimmer streak sweeping across the button.
/// 5. A pulsing Map Pin icon.
///
/// Optimized for performance by utilizing a single Ticker/AnimationController
/// and isolating repaints via [RepaintBoundary].
class NeonMapsCTAButton extends StatefulWidget {
  const NeonMapsCTAButton({super.key, required this.onTap, this.text});

  /// Callback when the button is tapped.
  final VoidCallback onTap;

  /// Optional custom text to display inside the button. Defaults to localized "Navigate to Maps".
  final String? text;

  @override
  State<NeonMapsCTAButton> createState() => _NeonMapsCTAButtonState();
}

class _NeonMapsCTAButtonState extends State<NeonMapsCTAButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // A single controller of 3.6 seconds to synchronize all animations:
    // - Shimmer sweep: 1 complete linear pass every 3.6 seconds.
    // - Sweep border rotation: 1 complete rotation every 3.6 seconds.
    // - Shadow pulse & icon scale: 1.8 seconds out, 1.8 seconds back.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final accentColor =
        context.appColors.brand; // App's primary neon green accent
    final buttonBgColor = isDark ? context.appColors.button : Colors.white;
    // final contentColor = isDark ? Colors.white : context.appColors.brand;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. RECOMMENDATION TEXT ABOVE CTA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              context.l10n.recommend_google_maps,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.appColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),

          // 2. NEON GLOW BUTTON ENCLOSED IN REPAINTBOUNDARY
          RepaintBoundary(
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final pulseVal = _pulseAnimation.value;

                  // 3-Layered Neon Glow Shadow Effect (softer in light mode)
                  final shadows = [
                    // Layer 1: Core (Tight, low blur, high opacity)
                    BoxShadow(
                      color: accentColor.withValues(
                        alpha: isDark
                            ? (0.6 + 0.2 * pulseVal)
                            : (0.2 + 0.1 * pulseVal),
                      ),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                    // Layer 2: Mid-Glow (Medium blur, medium opacity)
                    BoxShadow(
                      color: accentColor.withValues(
                        alpha: isDark
                            ? (0.3 + 0.2 * pulseVal)
                            : (0.1 + 0.1 * pulseVal),
                      ),
                      blurRadius: 16,
                      spreadRadius: 1.0 + 1.0 * pulseVal,
                    ),
                    // Layer 3: Falloff (Wide soft blur, low opacity)
                    BoxShadow(
                      color: accentColor.withValues(
                        alpha: isDark
                            ? (0.1 + 0.1 * pulseVal)
                            : (0.05 + 0.05 * pulseVal),
                      ),
                      blurRadius: 32,
                      spreadRadius: 2.0 + 2.0 * pulseVal,
                    ),
                  ];

                  return Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: buttonBgColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: shadows,
                    ),
                    child: CustomPaint(
                      foregroundPainter: NeonBorderPainter(
                        rotationAngle:
                            _controller.value * 2 * 3.141592653589793,
                        accentColor: accentColor,
                        borderRadius: 12.0,
                        borderWidth: 1.5,
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          // Dynamic shimmer gradient (solid colors to keep content fully visible continuously)
                          return LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    Colors.white,
                                    Colors.white,
                                    accentColor.withValues(alpha: 0.8),
                                    Colors.white,
                                    accentColor.withValues(alpha: 0.8),
                                    Colors.white,
                                    Colors.white,
                                  ]
                                : [
                                    accentColor,
                                    accentColor,
                                    Colors.white.withValues(alpha: 0.8),
                                    Colors.white,
                                    Colors.white.withValues(alpha: 0.8),
                                    accentColor,
                                    accentColor,
                                  ],
                            stops: const [
                              0.0,
                              0.35,
                              0.45,
                              0.5,
                              0.55,
                              0.65,
                              1.0,
                            ],
                            transform: _SlidingGradientTransform(
                              slidePercent: _controller.value,
                            ),
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Pin/Navigation Icon with pulse scaling
                              Transform.scale(
                                scale: 1.0 + 0.08 * pulseVal,
                                child: const Icon(
                                  Icons.location_on,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Button label text
                              Text(
                                widget.text ??
                                    context.l10n.navigate_to_destination,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom GradientTransform to handle the shimmer/sweep animation translation.
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Translate the gradient from off-screen left to off-screen right
    final double translation = bounds.width * (slidePercent * 3.0 - 1.5);
    return Matrix4.translationValues(translation, 0.0, 0.0);
  }
}

/// CustomPainter to draw a slowly rotating neon-glow SweepGradient border.
class NeonBorderPainter extends CustomPainter {
  final double rotationAngle;
  final Color accentColor;
  final double borderRadius;
  final double borderWidth;

  const NeonBorderPainter({
    required this.rotationAngle,
    required this.accentColor,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // A SweepGradient centered on the button, rotating slowly
    paint.shader = SweepGradient(
      center: Alignment.center,
      colors: [
        accentColor.withValues(alpha: 0.1),
        accentColor,
        accentColor.withValues(alpha: 0.1),
      ],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientRotation(rotationAngle),
    ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant NeonBorderPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth;
  }
}
