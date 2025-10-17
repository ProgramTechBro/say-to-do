import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:confetti/confetti.dart';
import '../controllers/HomeController.dart';
import '../utils/constants.dart';
import '../widgets/task_tile.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.08),
        child: AppBar(
          backgroundColor: Color(0xFFF5F5F5),
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: screenWidth * 0.38,
          leading: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: screenWidth * 0.04),
            child: SvgPicture.asset(
              'assets/icons/applogo.svg',
              height: screenHeight * 0.05,
            ),
          ),
          title: null,
          centerTitle: false,
          // actions: [
          //   GestureDetector(
          //     onTap: () {
          //       Get.toNamed('/premium', arguments: {'fromNamed': false});
          //     },
          //     child: Row(
          //       children: [
          //         Text(
          //           'Upgrade',
          //           style: TextStyle(
          //             color: Colors.black,
          //             fontFamily: 'Inter18',
          //             fontWeight: FontWeight.bold,
          //             fontSize: screenWidth * 0.0425,
          //           ),
          //         ),
          //         SizedBox(width: screenWidth * 0.02),
          //         SvgPicture.asset(
          //           'assets/icons/premium.svg',
          //           height: screenHeight * 0.032,
          //         ),
          //         SizedBox(width: screenWidth * 0.04),
          //       ],
          //     ),
          //   ),
          // ],
        ),
      ),
      body: Stack(
        children: [
          Obx(() => controller.isLoading.value
              ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
              : controller.tasks.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/notask.svg',
                  height: screenHeight * 0.07,
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'No tasks yet',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.055,
                    color: Colors.black,
                    fontFamily: 'Inter18',
                  ),
                ),
                SizedBox(height: screenHeight * 0.014),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth*0.02),
                  child: Text(
                    'Click the AI Voice voice button, Write Task, or Camera.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.038,
                      fontFamily: 'Inter18',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
              : _HomeContent(
            controller: controller,
          )),
          Obx(() => controller.showCelebration.value
              ? Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: controller.confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              blastDirection: -pi / 2,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink],
              numberOfParticles: 80,
              emissionFrequency: 0.1,
              minBlastForce: 15,
              maxBlastForce: 30,
              gravity: 0.3,
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeController controller;

  const _HomeContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.005,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: controller.updateSearchQuery,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search your tasks...',
                  hintStyle: const TextStyle(color: Colors.black38, fontFamily: 'Inter18'),
                  prefixIcon: const Icon(Icons.search, color: Colors.black38),
                  filled: true,
                  fillColor: Color(0xFFE9ECEF),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.018),
              Obx(() => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TabButton(
                      label: 'Due',
                      index: 0,
                      isSelected: controller.currentFilter.value == 0,
                      onTap: () => controller.setFilter(0),
                    ),
                    _TabButton(
                      label: 'Delay',
                      index: 1,
                      isSelected: controller.currentFilter.value == 1,
                      onTap: () => controller.setFilter(1),
                    ),
                    _TabButton(
                      label: 'Done',
                      index: 2,
                      isSelected: controller.currentFilter.value == 2,
                      onTap: () => controller.setFilter(2),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.016),
        Expanded(
          child: Obx(() => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.filteredTasks.isEmpty
              ? Center(
            child: Text(
              controller.currentFilter.value == 0
                  ? 'No Due tasks'
                  : controller.currentFilter.value == 1
                  ? 'No Delay tasks'
                  : 'No Done tasks',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.05,
                color: Colors.black,
                fontFamily: 'Inter18',
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemCount: controller.filteredTasks.length,
            itemBuilder: (context, index) {
              final task = controller.filteredTasks[index];
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final isNotCompleted = !task.isCompleted;
              final hasDueDate = task.dueDate != null;
              final dueBeforeToday = task.dueDate != null &&
                  DateTime(
                    task.dueDate!.year,
                    task.dueDate!.month,
                    task.dueDate!.day,
                  ).isBefore(today);
              final reminderInPast =
                  task.reminderDate != null && task.reminderDate!.isBefore(DateTime.now());
              final isOverdue = isNotCompleted && hasDueDate && (dueBeforeToday || reminderInPast);
              final cardColor = isOverdue ? const Color(0xFFFFDADA) : Color(0xFFE9ECEF);

              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TaskTile(
                  task: task,
                  onTaskToggle: controller.toggleTask,
                  onTaskEdit: (task) => controller.handleTaskEdit(context, task),
                  onTaskDelete: controller.deleteTask,
                ),
              );
            },
          )),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: screenWidth * 0.28,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6663F1) : Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter18',
            color: isSelected ? Colors.white : Colors.black38,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.035,
          ),
        ),
      ),
    );
  }
}