import 'package:flutter/material.dart';
import 'package:driver_app/shared/screens/place_picker_screen.dart';

class CarpoolLocationPickerItem extends StatelessWidget {
  final int index;
  final SelectedLocation stop;
  final VoidCallback onRemove;
  final bool canRemove;

  const CarpoolLocationPickerItem({
    super.key,
    required this.index,
    required this.stop,
    required this.onRemove,
    this.canRemove = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 12,
        backgroundColor: index == 0 ? Colors.green : Colors.red,
        child: Text(
          '${index + 1}',
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
      title: Text(
        stop.formattedAddress,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: canRemove
          ? IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: onRemove,
            )
          : null,
    );
  }
}
