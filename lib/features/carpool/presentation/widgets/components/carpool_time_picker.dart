import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CarpoolTimePicker extends StatelessWidget {
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  const CarpoolTimePicker({
    super.key,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: initialDateTime,
        onDateTimeChanged: onDateTimeChanged,
      ),
    );
  }
}
