// import 'package:driver_app/core/extensions/theme_extension.dart';
// // import 'package:flutter/material.dart';

// class RideHistoryTabSwitcher extends StatefulWidget {
//   final List<String> tabs;
//   final double height;
//   final double width;
//   final double radius;
//   final Function(int)? onTabChanged;
//   final int currentIndex;

//   final Color? selectedBackgroundColor;
//   final Color? unselectedBackgroundColor;
//   final Color? selectedTextColor;
//   final Color? unselectedTextColor;

//   const RideHistoryTabSwitcher({
//     super.key,
//     required this.tabs,
//     this.height = 50,
//     this.width = double.infinity,
//     this.radius = 10,
//     this.onTabChanged,
//     this.currentIndex = 0,
//     this.selectedBackgroundColor,
//     this.unselectedBackgroundColor,
//     this.selectedTextColor,
//     this.unselectedTextColor,
//   });

//   @override
//   State<RideHistoryTabSwitcher> createState() => _RideHistoryTabSwitcherState();
// }

// class _RideHistoryTabSwitcherState extends State<RideHistoryTabSwitcher>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late int _selectedIndex;

//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.currentIndex;
//     _tabController = TabController(length: widget.tabs.length, vsync: this);
//   }

//   @override
//   void didUpdateWidget(covariant RideHistoryTabSwitcher oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.currentIndex != widget.currentIndex) {
//       setState(() {
//         _selectedIndex = widget.currentIndex;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final selectedBg =
//         widget.selectedBackgroundColor ?? context.appColors.brand;
//     final unselectedBg = widget.unselectedBackgroundColor ?? Colors.transparent;

//     final selectedText =
//         widget.selectedTextColor ??
//         Theme.of(context).textTheme.bodyMedium!
//             .copyWith(
//               fontWeight: FontWeight.w600,
//               color: context.appColors.button,
//             )
//             .color!;

//     final unselectedText =
//         widget.unselectedTextColor ?? context.appColors.textPrimary;

//     return AppGradientBox(
//       // Border width
//       cornerRadius: 12,
//       child: Container(
//         height: widget.height,
//         width: widget.width,
//         decoration: BoxDecoration(
//           color: unselectedBg,
//           borderRadius: BorderRadius.circular(widget.radius),
//         ),
//         child: TabBar(
//           controller: _tabController,
//           dividerColor: Colors.transparent,
//           indicator: const BoxDecoration(),
//           indicatorSize: TabBarIndicatorSize.tab,
//           labelPadding: const EdgeInsets.all(5),
//           onTap: (i) {
//             setState(() => _selectedIndex = i);
//             widget.onTabChanged?.call(i);
//           },
//           tabs: List.generate(widget.tabs.length, (i) {
//             final selected = _selectedIndex == i;

//             BorderRadius borderRadius = BorderRadius.zero;
//             if (i == 0) {
//               // First tab → left rounded
//               borderRadius = BorderRadius.only(
//                 topLeft: Radius.circular(widget.radius),
//                 bottomLeft: Radius.circular(widget.radius),
//               );
//             } else if (i == widget.tabs.length - 1) {
//               // Last tab → right rounded
//               borderRadius = BorderRadius.only(
//                 topRight: Radius.circular(widget.radius),
//                 bottomRight: Radius.circular(widget.radius),
//               );
//             }

//             return Container(
//               height: widget.height,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: selected ? selectedBg : unselectedBg,
//                 borderRadius: borderRadius,
//               ),
//               child: FittedBox(
//                 fit: BoxFit.fitHeight,
//                 child: Padding(
//                   padding: const EdgeInsets.all(6.0),
//                   child: Text(
//                     widget.tabs[i],
//                     style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                       color: selected ? selectedText : unselectedText,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:driver_app/shared/widgets/custom_tap.dart';
import 'package:flutter/material.dart';

class RideHistoryTabSwitcher extends StatefulWidget {
  final List<String> tabs;
  final double height;
  final double width;
  final double radius;
  final Function(int)? onTabChanged;
  final int currentIndex;

  final Color? selectedBackgroundColor;
  final Color? unselectedBackgroundColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const RideHistoryTabSwitcher({
    super.key,
    required this.tabs,
    this.height = 50,
    this.width = double.infinity,
    this.radius = 10,
    this.onTabChanged,
    this.currentIndex = 0,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  @override
  State<RideHistoryTabSwitcher> createState() => _RideHistoryTabSwitcherState();
}

class _RideHistoryTabSwitcherState extends State<RideHistoryTabSwitcher>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void didUpdateWidget(covariant RideHistoryTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        _selectedIndex = widget.currentIndex;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedBg =
        widget.selectedBackgroundColor ?? context.appColors.brand;
    final unselectedBg = widget.unselectedBackgroundColor ?? Colors.transparent;

    final selectedText =
        widget.selectedTextColor ??
        Theme.of(context).textTheme.bodyMedium!
            .copyWith(
              fontWeight: FontWeight.w600,
              color: context.appColors.button,
            )
            .color!;

    final unselectedText =
        widget.unselectedTextColor ?? context.appColors.textPrimary;

    return PlainBackgroundWidget(
      isAllRounded: true,
      isPlain: true,
      radius: 20,
      padding: const EdgeInsetsGeometry.all(2),
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Row(
          children: List.generate(widget.tabs.length, (i) {
            final selected = _selectedIndex == i;

            BorderRadius borderRadius = BorderRadius.circular(16);
            return Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                curve: Curves.easeOutBack, // subtle bounce feel
                margin: EdgeInsets.all(selected ? 2 : 4),
                decoration: ShapeDecoration(
                  color: selected ? selectedBg : unselectedBg,
                  shape: RoundedSuperellipseBorder(borderRadius: borderRadius),
                ),
                child: CustomTap(
                  // borderRadius: borderRadius,
                  onTap: () {
                    setState(() => _selectedIndex = i);
                    widget.onTabChanged?.call(i);
                    // HapticFeedback.selectionClick();
                  },
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: selected ? selectedText : unselectedText,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 12,
                      ),
                      child: Text(widget.tabs[i]),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
