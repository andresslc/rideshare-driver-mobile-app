import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';

import '../../core/extensions/theme_extension.dart';

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.title,
    required this.value,
    this.isAmount = false,
    this.valueSuffix,
  });

  final String title;
  final String value;
  final bool isAmount;
  final String? valueSuffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Wrap title in FittedBox to auto-scale text if it is too long
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: Localizations.localeOf(context).languageCode == 'es'
                  ? 10
                  : 12,
            ),
          ),
        ),

        const SizedBox(height: 6),

        /// Wrap value in FittedBox for long amount numbers
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 48, width: 1.5, color: context.appColors.border);
  }
}

class RideStatsRow extends StatelessWidget {
  const RideStatsRow({
    super.key,
    this.totalTime,
    required this.totalDistance,
    required this.totalAmount,
    this.totalAmountSuffix,
    this.padding = const EdgeInsets.all(10),
  });

  final String? totalTime;
  final String totalDistance;
  final String totalAmount;
  final String? totalAmountSuffix;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: padding,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: context.appColors.border, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Total Time / Avg Time
              if (totalTime != null) ...[
                _StatItem(title: context.l10n.avg_time, value: totalTime!),
                _VerticalDivider(),
              ],

              /// Total Distance
              _StatItem(
                title: context.l10n.total_distance,
                value: totalDistance,
              ),
              _VerticalDivider(),

              /// Total Amount / Total Fare
              _StatItem(
                title: context.l10n.estimated_fare,
                value: totalAmount,
                isAmount: true,
                valueSuffix: totalAmountSuffix,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// import 'package:driver_app/core/extensions/context_extension.dart';
// import 'package:flutter/material.dart';

// import '../../core/extensions/theme_extension.dart';

// class _StatItem extends StatelessWidget {
//   const _StatItem({
//     required this.title,
//     required this.value,
//     this.isAmount = false,
//     this.valueSuffix,
//   });

//   final String title;
//   final String value;
//   final bool isAmount;
//   final String? valueSuffix;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         /// Wrap title in FittedBox to auto-scale text if it is too long
//         FittedBox(
//           fit: BoxFit.scaleDown,
//           child: Text(
//             title,
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.titleSmall?.copyWith(
//               fontSize: Localizations.localeOf(context).languageCode == 'es'
//                   ? 12
//                   : 14,
//             ),
//           ),
//         ),

//         const SizedBox(height: 6),

//         /// Wrap value in FittedBox for long amount numbers
//         FittedBox(
//           fit: BoxFit.scaleDown,
//           child: Text(
//             value,
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontSize: Localizations.localeOf(context).languageCode == 'es'
//                   ? 12
//                   : 14,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _VerticalDivider extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(height: 48, width: 1.5, color: context.appColors.border);
//   }
// }

// class RideStatsRow extends StatelessWidget {
//   const RideStatsRow({
//     super.key,
//     this.totalTime,
//     required this.totalDistance,
//     required this.totalAmount,
//     this.totalAmountSuffix,
//   });

//   final String? totalTime;
//   final String totalDistance;
//   final String totalAmount;
//   final String? totalAmountSuffix;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             border: Border(
//               top: BorderSide(color: context.appColors.border, width: 1),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               /// Total Time / Avg Time
//               if (totalTime != null) ...[
//                 _StatItem(title: context.l10n.avg_time, value: totalTime!),
//                 _VerticalDivider(),
//               ],

//               /// Total Distance
//               _StatItem(
//                 title: context.l10n.total_distance,
//                 value: totalDistance,
//               ),
//               _VerticalDivider(),

//               /// Total Amount / Total Fare
//               _StatItem(
//                 title: context.l10n.estimated_fare,
//                 value: totalAmount,
//                 isAmount: true,
//                 valueSuffix: totalAmountSuffix,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
