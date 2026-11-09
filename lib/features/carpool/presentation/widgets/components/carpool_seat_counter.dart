import 'package:flutter/material.dart';

class CarpoolSeatCounter extends StatelessWidget {
  final int count;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const CarpoolSeatCounter({
    super.key,
    required this.count,
    this.min = 1,
    this.max = 4,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: count > min ? () => onChanged(count - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '$count',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: count < max ? () => onChanged(count + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
