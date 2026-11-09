import 'package:flutter/material.dart';
import '../../core/constants/app_images.dart';
import '../../core/extensions/theme_extension.dart';
import 'package:flutter/services.dart';

enum ScaffoldBackgroundType { singlShadow, doubleShadow }

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    this.scrollable = false,
    // this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    // this.scrollable = false,
    this.appBar,
    this.useGradientBackground = true,
    this.safeArea = true,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation =
        FloatingActionButtonLocation.centerFloat,
    this.resizeToAvoidBottomInset,
    this.whichBackground = ScaffoldBackgroundType.singlShadow,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool scrollable;
  final PreferredSizeWidget? appBar;
  final bool useGradientBackground;
  final bool safeArea;

  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final ScaffoldBackgroundType whichBackground;

  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? resizeToAvoidBottomInset;
  AssetImage get backgroundImage {
    switch (whichBackground) {
      case ScaffoldBackgroundType.singlShadow:
        return const AssetImage(AppImages.bgOne);
      case ScaffoldBackgroundType.doubleShadow:
        return const AssetImage(AppImages.bgTwo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bool isDarkMode = context.isDark;
    final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
    );

    final background =
        useGradientBackground && colors.backgroundGradient != null
        ? BoxDecoration(
            gradient: colors.backgroundGradient,
            image: DecorationImage(fit: BoxFit.fill, image: backgroundImage),
          )
        : BoxDecoration(color: colors.background);

    final content = Padding(padding: padding, child: child);

    final body = scrollable ? SingleChildScrollView(child: content) : content;

    final wrapped = safeArea ? SafeArea(child: body) : body;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: DecoratedBox(
        decoration: background,
        child: Scaffold(
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          extendBody: extendBody,
          drawer: drawer,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: wrapped,
        ),
      ),
    );
  }
}

// enum ScaffoldBackgroundType { singlShadow, doubleShadow }

// class AppScaffold extends StatelessWidget {
//   const AppScaffold({
//     super.key,
//     required this.child,
//     this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//     this.scrollable = false,
//     // this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//     // this.scrollable = false,
//     this.appBar,
//     this.useGradientBackground = true,
//     this.safeArea = true,
//     this.extendBodyBehindAppBar = false,
//     this.extendBody = false,
//     this.drawer,
//     this.bottomNavigationBar,
//     this.floatingActionButton,
//     this.floatingActionButtonLocation =
//         FloatingActionButtonLocation.centerFloat,
//     this.resizeToAvoidBottomInset,
//     this.whichBackground = ScaffoldBackgroundType.singlShadow,
//   });

//   final Widget child;
//   final EdgeInsets padding;
//   final bool scrollable;
//   final PreferredSizeWidget? appBar;
//   final bool useGradientBackground;
//   final bool safeArea;

//   final bool extendBodyBehindAppBar;
//   final bool extendBody;
//   final ScaffoldBackgroundType whichBackground;

//   final Widget? drawer;
//   final Widget? bottomNavigationBar;
//   final Widget? floatingActionButton;
//   final FloatingActionButtonLocation? floatingActionButtonLocation;
//   final bool? resizeToAvoidBottomInset;
//   AssetImage get backgroundImage {
//     switch (whichBackground) {
//       case ScaffoldBackgroundType.singlShadow:
//         return const AssetImage(AppImages.bgOne);
//       case ScaffoldBackgroundType.doubleShadow:
//         return const AssetImage(AppImages.bgTwo);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.appColors;
//     final background =
//         useGradientBackground && colors.backgroundGradient != null
//         ? BoxDecoration(
//             gradient: colors.backgroundGradient,
//             image: DecorationImage(fit: BoxFit.fill, image: backgroundImage),
//           )
//         : BoxDecoration(color: colors.background);

//     final content = Padding(padding: padding, child: child);

//     final body = scrollable ? SingleChildScrollView(child: content) : content;

//     final wrapped = safeArea ? SafeArea(child: body) : body;

//     return DecoratedBox(
//       decoration: background,
//       child: Scaffold(
//         resizeToAvoidBottomInset: resizeToAvoidBottomInset,
//         extendBodyBehindAppBar: extendBodyBehindAppBar,
//         extendBody: extendBody,
//         drawer: drawer,
//         bottomNavigationBar: bottomNavigationBar,

//         floatingActionButton: floatingActionButton,
//         floatingActionButtonLocation: floatingActionButtonLocation,
//         backgroundColor: Colors.transparent,
//         appBar: appBar,
//         body: wrapped,
//       ),
//     );
//   }
// }
