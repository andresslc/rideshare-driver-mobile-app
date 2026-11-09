import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CarpoolFlowTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;

  const CarpoolFlowTitle({
    super.key,
    required this.title,
    this.onBack,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 52,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            if (showBackButton) ...[
              IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
              Gap(10),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: showBackButton
                    ? TextAlign.start
                    : TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
