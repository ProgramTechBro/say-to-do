// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:lottie/lottie.dart';
// import 'package:double_tap_to_exit/double_tap_to_exit.dart';
// import '../controllers/MainNavBarController.dart';
// import '../utils/constants.dart';
// import 'home_screen.dart';
// import 'calendar_page.dart';
// import 'analytics_page.dart';
// import 'settings_page.dart';
//
// class MainNavBarScreen extends StatefulWidget {
//   const MainNavBarScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MainNavBarScreen> createState() => _MainNavBarScreenState();
// }
//
// class _MainNavBarScreenState extends State<MainNavBarScreen> {
//   final MainNavBarController controller = Get.put(MainNavBarController());
//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> pages = [
//       const HomeScreen(),
//       const CalendarPage(),
//       const AnalyticsPage(),
//       SettingsPage(),
//     ];
//
//     return DoubleTapToExit(
//       snackBar: SnackBar(
//         content: const Text(
//           'Double tap to exit the app',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: AppColors.primaryColor,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       child: Obx(() => Stack(
//         children: [
//           Scaffold(
//             backgroundColor: const Color(0xFFF7F7F7),
//             body: Stack(
//               children: [
//                 pages[controller.selectedIndex.value],
//                 if (controller.selectedIndex.value == 0)
//                   _ExpandableFab(controller: controller),
//               ],
//             ),
//             bottomNavigationBar: _CustomBottomNavBar(controller: controller),
//           ),
//           if (controller.showVoiceDialog.value)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black.withOpacity(0.7),
//                 child: Center(
//                   child: Material(
//                     color: Colors.transparent,
//                     child: Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Container(
//                         width: 280,
//                         height: 320,
//                         decoration: BoxDecoration(
//                           color: AppColors.primaryColor,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text(
//                               'Recording...',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Lottie.asset(
//                               'assets/Lottie/recording.json',
//                               width: 120,
//                               height: 120,
//                               repeat: true,
//                             ),
//                             const SizedBox(height: 24),
//                             SizedBox(
//                               width: 100,
//                               height: 40,
//                               child: ElevatedButton(
//                                 onPressed: controller.stopVoiceRecordingAndAnalyze,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFFF8F8FA),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   padding: EdgeInsets.zero,
//                                 ),
//                                 child: const Text(
//                                   'Stop',
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           if (controller.showAnalyzingOverlay.value)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black.withOpacity(0.85),
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Lottie.asset(
//                         'assets/Lottie/analyzing.json',
//                         width: 120,
//                         height: 120,
//                         repeat: true,
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Analyzing and adding task...',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           decoration: TextDecoration.none,
//                           backgroundColor: Colors.transparent,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       )),
//     );
//   }
// }
//
// class _ExpandableFab extends StatelessWidget {
//   final MainNavBarController controller;
//
//   const _ExpandableFab({required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//       ),
//     );
//     return Positioned(
//       right: 20,
//       bottom: 20,
//       child: Column(
//         children: [
//           _SvgFab(
//             assetPath: 'assets/icons/camera.svg',
//             onTap: () => controller.startImageTaskFlow(context),
//             backgroundColor: Colors.white,
//             useFullSize: false,
//             iconPadding: const EdgeInsets.all(10),
//           ),
//           const SizedBox(height: 12),
//           _SvgFab(
//             assetPath: 'assets/icons/voicetask.svg',
//             onTap: controller.startVoiceTaskFlow,
//             backgroundColor: AppColors.primaryColor,
//             useFullSize: true,
//           ),
//           const SizedBox(height: 12),
//           _SvgFab(
//             assetPath: 'assets/icons/addtask.svg',
//             onTap: () => controller.addManualTask(context),
//             backgroundColor: Colors.white,
//             useFullSize: false,
//             iconPadding: const EdgeInsets.all(10),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _SvgFab extends StatelessWidget {
//   final String assetPath;
//   final VoidCallback onTap;
//   final Color backgroundColor;
//   final bool useFullSize;
//   final EdgeInsets? iconPadding;
//
//   const _SvgFab({
//     required this.assetPath,
//     required this.onTap,
//     required this.backgroundColor,
//     this.useFullSize = false,
//     this.iconPadding,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton(
//       heroTag: assetPath,
//       onPressed: onTap,
//       backgroundColor: backgroundColor,
//       elevation: 0,
//       shape: const CircleBorder(),
//       child: Padding(
//         padding: iconPadding ?? EdgeInsets.zero,
//         child: SvgPicture.asset(
//           assetPath,
//           width: useFullSize ? 44 : 24,
//           height: useFullSize ? 44 : 24,
//           fit: useFullSize ? BoxFit.cover : BoxFit.contain,
//           color: useFullSize ? null : AppColors.primaryColor,
//         ),
//       ),
//     );
//   }
// }
//
// class _CustomBottomNavBar extends StatelessWidget {
//   final MainNavBarController controller;
//
//   const _CustomBottomNavBar({required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       _NavBarItem(
//         label: 'Home',
//         selectedIcon: 'assets/icons/homes.svg',
//         unselectedIcon: 'assets/icons/homeun.svg',
//       ),
//       _NavBarItem(
//         label: 'Calendar',
//         selectedIcon: 'assets/icons/calendars.svg',
//         unselectedIcon: 'assets/icons/calendarun.svg',
//       ),
//       _NavBarItem(
//         label: 'Analytics',
//         selectedIcon: 'assets/icons/charts.svg',
//         unselectedIcon: 'assets/icons/chartun.svg',
//       ),
//       _NavBarItem(
//         label: 'Settings',
//         selectedIcon: 'assets/icons/settings.svg',
//         unselectedIcon: 'assets/icons/settingun.svg',
//       ),
//     ];
//
//     return Container(
//       height: 80,
//       color: Colors.white,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: List.generate(items.length, (index) {
//           final selected = controller.selectedIndex.value == index;
//           return Expanded(
//             child: GestureDetector(
//               onTap: () => controller.onTabSelected(index),
//               behavior: HitTestBehavior.opaque,
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 10, bottom: 16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SvgPicture.asset(
//                       selected ? items[index].selectedIcon : items[index].unselectedIcon,
//                       width: 22,
//                       height: 22,
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       items[index].label,
//                       style: TextStyle(
//                         fontFamily: 'Inter18',
//                         color: selected ? const Color(0xFF0088FF) : const Color(0xFFBDBDBD),
//                         fontWeight: FontWeight.w600,
//                         fontSize: 11,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
//
// class _NavBarItem {
//   final String label;
//   final String selectedIcon;
//   final String unselectedIcon;
//
//   _NavBarItem({
//     required this.label,
//     required this.selectedIcon,
//     required this.unselectedIcon,
//   });
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:double_tap_to_exit/double_tap_to_exit.dart';
import '../controllers/MainNavBarController.dart';
import '../utils/constants.dart';
import '../widgets/AnalyzingOverlay.dart';
import '../widgets/VoiceRecordingOverlay.dart';
import 'home_screen.dart';
import 'calendar_page.dart';
import 'analytics_page.dart';
import 'settings_page.dart';

class MainNavBarScreen extends StatefulWidget {
  const MainNavBarScreen({Key? key}) : super(key: key);

  @override
  State<MainNavBarScreen> createState() => _MainNavBarScreenState();
}

class _MainNavBarScreenState extends State<MainNavBarScreen> {
  final MainNavBarController controller = Get.put(MainNavBarController());

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final List<Widget> pages = [
      const HomeScreen(),
      const CalendarPage(),
      const AnalyticsPage(),
      SettingsPage(),
    ];

    return DoubleTapToExit(
      snackBar: SnackBar(
        content: Text(
          'Double tap to exit the app',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.04,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(screenWidth * 0.03),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
      ),
      child: WillPopScope(
        onWillPop: () async {
          if (controller.showVoiceDialog.value) {
            await controller.cancelVoiceRecording();
            return false;
          }
          if(controller.showAnalyzingOverlay.value){
            Get.snackbar('Processing...', 'Please wait your input is being processed');
            return false;
          }
          if (controller.selectedIndex.value != 0) {
            controller.selectedIndex.value = 0;
            return false;
          }
          return true;
        },
        child: Obx(() => Stack(
          children: [
            Scaffold(
              backgroundColor: Color(0xFFF5F5F5),
              extendBody: true,
              body: SafeArea(
                child: Stack(
                  children: [
                    pages[controller.selectedIndex.value],
                    if (controller.selectedIndex.value == 0)
                      _ExpandableFab(controller: controller, screenWidth: screenWidth, screenHeight: screenHeight),
                  ],
                ),
              ),
              bottomNavigationBar: SafeArea(
                child: Container(
                  height: screenHeight*0.08,
                  child: _CustomBottomNavBar(
                    controller: controller,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ),
              ),
            ),
            // if (controller.showVoiceDialog.value)
            //   VoiceRecordingOverlay(controller: controller),
            if (controller.showAnalyzingOverlay.value)
              const AnalyzingOverlay(),
          ],
        )),
      ),
    );
  }
}

class _ExpandableFab extends StatelessWidget {
  final MainNavBarController controller;
  final double screenWidth;
  final double screenHeight;

  const _ExpandableFab({
    required this.controller,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final systemNavBarHeight = MediaQuery.of(context).padding.bottom;

    return Positioned(
      right: screenWidth * 0.04,
      bottom: screenHeight * 0.01 + systemNavBarHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SvgFab(
            assetPath: 'assets/icons/addtask.svg',
            onTap: () => controller.addManualTask(context),
            backgroundColor: Colors.white,
            useFullSize: false,
            iconPadding: EdgeInsets.all(screenWidth * 0.025),
            screenWidth: screenWidth,
          ),
          SizedBox(height: screenHeight * 0.01),
          _SvgFab(
            assetPath: 'assets/icons/camera.svg',
            onTap: () => controller.startImageTaskFlow(context),
            backgroundColor: Colors.white,
            useFullSize: false,
            iconPadding: EdgeInsets.all(screenWidth * 0.02),
            screenWidth: screenWidth,
          ),
          SizedBox(height: screenHeight * 0.01),
          _SvgFab(
            assetPath: 'assets/icons/voicetask.svg',
            onTap: () => controller.startVoiceTaskFlow(context),
            backgroundColor: AppColors.primaryColor,
            useFullSize: true,
            iconPadding: EdgeInsets.symmetric(horizontal:screenWidth * 0.03,),
            screenWidth: screenWidth,
          ),
          SizedBox(height: screenHeight * 0.01),
        ],
      ),
    );
  }
}

class _SvgFab extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;
  final Color backgroundColor;
  final bool useFullSize;
  final EdgeInsets? iconPadding;
  final double screenWidth;

  const _SvgFab({
    required this.assetPath,
    required this.onTap,
    required this.backgroundColor,
    this.useFullSize = false,
    this.iconPadding,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: assetPath,
      onPressed: onTap,
      backgroundColor: backgroundColor,
      elevation: 0,
      shape: const CircleBorder(),
      child: Padding(
        padding: iconPadding ?? EdgeInsets.zero,
        child: SvgPicture.asset(
          assetPath,
          width: useFullSize ? screenWidth * 0.11 : screenWidth * 0.07,
          height: useFullSize ? screenWidth * 0.11 : screenWidth * 0.07,
          fit: useFullSize ? BoxFit.cover : BoxFit.contain,
          color: useFullSize ? null : AppColors.primaryColor,
        ),
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final MainNavBarController controller;
  final double screenWidth;
  final double screenHeight;

  const _CustomBottomNavBar({
    required this.controller,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavBarItem(
        label: 'Home',
        selectedIcon: 'assets/icons/homes.svg',
        unselectedIcon: 'assets/icons/homeun.svg',
      ),
      _NavBarItem(
        label: 'Calendar',
        selectedIcon: 'assets/icons/calendars.svg',
        unselectedIcon: 'assets/icons/calendarun.svg',
      ),
      _NavBarItem(
        label: 'Analytics',
        selectedIcon: 'assets/icons/charts.svg',
        unselectedIcon: 'assets/icons/chartun.svg',
      ),
      _NavBarItem(
        label: 'Settings',
        selectedIcon: 'assets/icons/settings.svg',
        unselectedIcon: 'assets/icons/settingun.svg',
      ),
    ];

    return Container(
      height: screenHeight * 0.1,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.005,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(items.length, (index) {
          final selected = controller.selectedIndex.value == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.onTabSelected(index),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.01,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      selected ? items[index].selectedIcon : items[index].unselectedIcon,
                      width: screenWidth * 0.055,
                      height: screenWidth * 0.055,
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      items[index].label,
                      style: TextStyle(
                        fontFamily: 'Inter18',
                        color: selected ? const Color(0xFF6663F1) : const Color(0xFFBDBDBD),
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.0275,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavBarItem {
  final String label;
  final String selectedIcon;
  final String unselectedIcon;

  _NavBarItem({
    required this.label,
    required this.selectedIcon,
    required this.unselectedIcon,
  });
}