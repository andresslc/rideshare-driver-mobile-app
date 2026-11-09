import 'package:driver_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ToggleShape extends StatelessWidget {
  const ToggleShape({super.key, this.isReverse = false});
  final bool isReverse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 13,
      height: 21,
      padding: EdgeInsets.symmetric(
        vertical: isReverse ? 1 : 2,
        horizontal: isReverse ? 1 : 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.5),
        color: isReverse ? Colors.transparent : AppColors.brand,
        border: isReverse ? Border.all(color: AppColors.brand, width: 1) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: isReverse
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircleAvatar(
              backgroundColor: isReverse
                  ? AppColors.brand
                  : AppColors.lightBackground,
            ),
          ),
        ],
      ),
    );
  }
}
