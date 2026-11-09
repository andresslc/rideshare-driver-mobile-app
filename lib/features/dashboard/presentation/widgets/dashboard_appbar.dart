import 'package:driver_app/core/constants/app_icons.dart';
import 'package:driver_app/core/core.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../../../../shared/widgets/glow_button.dart';

class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvailableRidesTap;
  final bool isOnline;
  final ZoomDrawerController? zoomController;

  const DashboardAppBar({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.onAvailableRidesTap,
    this.isOnline = false,
    this.zoomController,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasPendingRides = ref.watch(
      rideSocketProvider.select((s) => s.incomingRides.isNotEmpty),
    );
    // final rideCount = ref.watch(
    //   rideSocketProvider.select((s) => s.incomingRides.length),
    // );
    final canOpenAvailableRides = isOnline && onAvailableRidesTap != null;
    // final availableRidesButton = IconButton(
    //   onPressed: canOpenAvailableRides ? onAvailableRidesTap : () {},
    //   padding: EdgeInsets.zero,
    //   icon: Opacity(
    //     opacity: isOnline ? 1.0 : 0.5,
    //     child: Image.asset(
    //       context.isDark
    //           ? AppIcons.availablerides
    //           : AppIcons.lightavailablerides,
    //       width: context.isDark
    //           ? context.screenWidth * 0.12
    //           : context.screenWidth * 0.09,
    //       height: context.isDark
    //           ? context.screenWidth * 0.12
    //           : context.screenWidth * 0.09,
    //       fit: context.isDark ? BoxFit.cover : null,
    //     ),
    //   ),
    // );

    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(title)],
      ),
      centerTitle: true,
      // leading: Builder(
      //   builder: (context) => IconButton(
      //     onPressed: () {
      //       zoomController?.toggle?.call();

      //       // Scaffold.of(context).openDrawer();
      //     },
      //     icon: Image.asset(
      //       AppIcons.drawer,
      //       width: ContextExtension(context).screenWidth * 0.10,
      //       height: ContextExtension(context).screenWidth * 0.10,
      //     ),
      //   ),
      // ),
      leading: Row(
        children: [
          const SizedBox.square(dimension: 10),
          SizedBox(
            height: 36,
            width: 36,
            child: GlowButton(
              onTap: () => zoomController?.toggle?.call(),
              child: Image.asset(
                AppIcons.drawer,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.brand
                    : Colors.white,
                width: ContextExtension(context).screenWidth * 0.10,
                height: ContextExtension(context).screenWidth * 0.10,
              ),
              // child: Icon(
              //   Icons.menu_rounded,
              //   color: (!context.isDark) ? Colors.white : null,

              //   // AppIcons.pendingRides,
              //   // color: (!context.isDark) ? Colors.white : null,
              // ),
            ),
          ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1),
          // Center(
          //   child: SizedBox(
          //     height: 46,
          //     width: 46,
          //     child: GlowButton(
          //       onTap: () {
          //         zoomController?.toggle?.call();
          //       },
          //       // size: 40,
          //       child: Icon(
          //         Icons.menu_rounded,
          //         color: (context.isDark)
          //             ? context.appColors.brand
          //             : Colors.white,
          //         size: 30,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      actions: [
        // _RideRequestsAction(
        //   isOnline: isOnline,
        //   hasPendingRides: isOnline && hasPendingRides,
        //   onTap: onAvailableRidesTap,
        // ),
        // if (isOnline)
        Badge(
          // label: Text(rideCount.toString()),
          // largeSize: ,
          // largeSize: 10,
          isLabelVisible: isOnline && hasPendingRides,

          // largeSize: 5,
          // alignment: Alignment.topRight,
          label: Container(
            width: 2,
            height: 2,

            decoration: BoxDecoration(
              color: Colors.red,

              shape: BoxShape.circle,
            ),
          ),
          // backgroundColor: context.appColors.brand,
          offset: const Offset(8, -5),

          child: SizedBox(
            height: 36,
            width: 36,
            child: Opacity(
              opacity: isOnline ? 1.0 : 0.5,
              child: GlowButton(
                onTap: canOpenAvailableRides ? onAvailableRidesTap : () {},
                child: Image.asset(
                  AppIcons.pendingRides,
                  color: (!context.isDark) ? Colors.white : null,
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1),
        SizedBox(width: 6),
        SizedBox(
          height: 36,
          width: 36,
          child: GlowButton(
            onTap: onNotificationTap,
            child: Image.asset(
              AppIcons.notification,
              color: (!context.isDark) ? Colors.white : null,
            ),
          ),
        ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1),
        SizedBox(width: 12),
        // IconButton(
        //   onPressed: onNotificationTap,
        //   padding: EdgeInsets.zero,
        //   icon: Image.asset(
        //     context.isDark ? AppIcons.notificationIcon : AppIcons.lightmodenoti,
        //     width: context.isDark
        //         ? context.screenWidth * 0.12
        //         : context.screenWidth * 0.09,
        //     height: context.isDark
        //         ? context.screenWidth * 0.11
        //         : context.screenWidth * 0.09,
        //     fit: context.isDark ? BoxFit.cover : null,
        //   ),
        // ),
      ],
    ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05);
    ;
  }
}

class _RideRequestsAction extends StatelessWidget {
  const _RideRequestsAction({
    required this.isOnline,
    required this.hasPendingRides,
    required this.onTap,
  });

  final bool isOnline;
  final bool hasPendingRides;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: hasPendingRides ? 'Ride requests waiting' : 'Ride requests',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: onTap,
            padding: EdgeInsets.zero,
            icon: Opacity(
              opacity: isOnline ? 1.0 : 0.55,
              child: Image.asset(
                context.isDark
                    ? AppIcons.availablerides
                    : AppIcons.lightavailablerides,
                width: context.isDark
                    ? ContextExtension(context).screenWidth * 0.12
                    : ContextExtension(context).screenWidth * 0.09,
                height: context.isDark
                    ? ContextExtension(context).screenWidth * 0.12
                    : ContextExtension(context).screenWidth * 0.09,
                fit: context.isDark ? BoxFit.cover : null,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: hasPendingRides ? 1 : 0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  scale: hasPendingRides ? 1 : 0.7,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: context.appColors.brand,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            Theme.of(context).appBarTheme.backgroundColor ??
                            Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.appColors.brand.withValues(
                            alpha: 0.45,
                          ),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
