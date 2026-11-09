import 'package:flutter/material.dart';
import 'package:driver_app/shared/widgets/toggle_shape.dart';

class LocationStepWidget extends StatelessWidget {
  final int index;
  final String stopName;
  final String address;
  final bool isLast;
  final ColorScheme colors;
  final TextTheme textTheme;

  const LocationStepWidget({
    super.key,
    required this.index,
    required this.stopName,
    required this.address,
    required this.isLast,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stepper column
          Column(
            children: [
              ToggleShape(isReverse: isLast),

              if (!isLast)
                Expanded(
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 4,
                    children: List.generate(
                      20,
                      (_) => Container(
                        width: 1,
                        height: 2,
                        color: colors.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stopName,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
