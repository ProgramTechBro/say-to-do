import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../controllers/NotificationController.dart';



class NotificationScreen extends StatelessWidget {
  NotificationScreen({Key? key}) : super(key: key);
  final NotificationScreenController controller = Get.put(
    NotificationScreenController(),
  );

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent,
    //     statusBarIconBrightness: Brightness.dark,
    //   ),
    // );
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.04),
          Theme(
            data: Theme.of(context).copyWith(
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.all(Colors.white),
                trackColor: MaterialStateProperty.resolveWith<Color>(
                  (states) =>
                      states.contains(MaterialState.selected)
                          ? Color(0xFF0088FF)
                          : Color(0xFF5B5B5B),
                ),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSwitchTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive alerts for new tasks and updates',
                    value: controller.pushNotifications,
                  ),
                  _divider(),
                  _buildSwitchTile(
                    title: 'Task Reminders',
                    subtitle: 'Get notified before task deadlines',
                    value: controller.taskReminders,
                  ),
                  _divider(),
                  _buildSwitchTile(
                    title: 'Due Date Alerts',
                    subtitle: 'Receive alerts on the day tasks are due',
                    value: controller.dueDateAlerts,
                  ),
                  _divider(),
                  _buildSwitchTile(
                    title: 'Weekly Summary',
                    subtitle: 'Receive a weekly report of your progress',
                    value: controller.weeklySummary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    thickness: 0.5,
    indent: 16,
    endIndent: 16,
    color: Color(0xFFE0E0E0),
  );

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required RxBool value,
  }) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            FlutterSwitch(
              width: 48,
              height: 28,
              toggleSize: 22,
              value: value.value,
              onToggle: (val) => value.value = val,
              activeColor: Color(0xFF0088FF),
              inactiveColor: Color(0xFF5B5B5B),
              toggleColor: Colors.white,
              padding: 3,
              showOnOff: false,
            ),
          ],
        ),
      ),
    );
  }
}
