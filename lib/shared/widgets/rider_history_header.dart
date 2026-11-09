import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:flutter/material.dart';

class RideTopInfo extends StatelessWidget {
  final String rideType;
  final String status;

  /// jab true ho, sirf 1 title show hoga
  final bool singleTitleMode;

  /// single title ka text (optional)
  final String? singleTitle;

  const RideTopInfo({
    super.key,
    required this.rideType,
    required this.status,
    this.singleTitleMode = false, // default: jaisa hai waisa hi
    this.singleTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (singleTitleMode) {
      return Text(
        singleTitle ?? rideType,
        style: context.textTheme.headlineMedium?.copyWith(),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(rideType, style: context.textTheme.bodyMedium),
        Text(
          status,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: _statusColor(status),
          ),
        ),
      ],
    );
  }
}

Color _statusColor(String status) {
  final normalized = status.toLowerCase();
  if (normalized.contains('complet')) return Colors.green;
  if (normalized.contains('cancel')) return Colors.red;
  return Colors.green;
}


// jb aap ko sirf title chaye ho to no status no ridetype 
//   const RideTopInfo(
          //   rideType: 'Economy Ride',
          //   status: 'Completed',
          //   singleTitleMode: true,
          //   singleTitle:
          //       'You have reached the pickup point!', // ya jo bhi text chaho
          // ),
