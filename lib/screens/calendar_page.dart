import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import '../utils/CalenderView.dart';
import '../widgets/task_tile.dart';
import '../utils/constants.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
  List<Task> _tasksForDate = [];
  bool _isLoading = true;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late ConfettiController _confettiController;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _loadTasksForDate(_selectedDate);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadTasksForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
    });
    final allTasks = await _dbHelper.getTasks();
    setState(() {
      _tasksForDate =
          allTasks
              .where(
                (t) =>
                    t.dueDate != null &&
                    t.dueDate!.year == date.year &&
                    t.dueDate!.month == date.month &&
                    t.dueDate!.day == date.day,
              )
              .toList();
      _tasksForDate.sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        if (a.priority != b.priority) return b.priority.compareTo(a.priority);
        return a.createdAt.compareTo(b.createdAt);
      });
      _isLoading = false;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadTasksForDate(date);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _onDateSelected(picked);
    }
  }

  void _onTaskToggle(Task t) async {
    final updatedTask = t.copyWith(isCompleted: !t.isCompleted);
    await _dbHelper.updateTask(updatedTask);
    _loadTasksForDate(_selectedDate);
    if (!t.isCompleted) {
      setState(() {
        _showCelebration = true;
      });
      _confettiController.play();
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted)
          setState(() {
            _showCelebration = false;
          });
      });
    }
  }

  void _onTaskEdit(Task t) async {
    // You can implement edit navigation if needed
  }

  void _onTaskDelete(String id) async {
    await _dbHelper.deleteTask(id);
    _loadTasksForDate(_selectedDate);
  }

  Widget _buildCalendarBar() {
    final days = List.generate(7, (i) {
      final date = _selectedDate.subtract(
        Duration(days: _selectedDate.weekday - 1 - i),
      );
      final isSelected =
          date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
      return Expanded(
        child: GestureDetector(
          onTap: () => _onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat.E().format(date).substring(0, 1),
                  style: TextStyle(color:isSelected ? Colors.white : Colors.black,fontSize: 15,fontWeight: FontWeight.bold,fontFamily: 'Inter18'),
                ),
                const SizedBox(height: 2),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                      fontFamily: 'Inter18'
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
    return Row(children: days);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Color(0xFFF7F7F7),
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Inter18'
          ),
        ),
        centerTitle: false,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 12.0),
        //     child: GestureDetector(
        //       onTap: (){
        //         Get.toNamed('/premium', arguments: {'fromNamed': false});
        //       },
        //       child: Row(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Text(
        //             'Upgrade',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontWeight: FontWeight.bold,
        //               fontFamily: 'Inter18',
        //               fontSize: 16,
        //             ),
        //           ),
        //           const SizedBox(width: 6),
        //           SvgPicture.asset('assets/icons/premium.svg', height: 24),
        //         ],
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalendarView(
                  onDateSelected: _onDateSelected,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Row(
                //       children: [
                //         Text(
                //           DateFormat('MMMM yyyy').format(_selectedDate),
                //           style: const TextStyle(
                //             fontWeight: FontWeight.bold,
                //             fontSize: 18,
                //             fontFamily: 'Inter18',
                //           ),
                //         ),
                //         IconButton(
                //           icon: const Icon(
                //             Icons.arrow_drop_down,
                //             color: Colors.black,
                //           ),
                //           onPressed: _pickDate,
                //         ),
                //       ],
                //     ),
                //     TextButton(
                //       onPressed: () => _onDateSelected(DateTime.now()),
                //       child: const Text(
                //         'Today',
                //         style: TextStyle(
                //           color: Colors.blue,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 8),
                 //_buildCalendarBar(),
                const SizedBox(height: 16),
                Text(
                  'Tasks for ${DateFormat('MMMM d').format(_selectedDate)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter18',
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _tasksForDate.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 60,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No tasks for this date',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80,),
                    itemCount: _tasksForDate.length,
                    itemBuilder: (context, index) {
                      final task = _tasksForDate[index];
                      return TaskTile(
                        task: task,
                        onTaskToggle: _onTaskToggle,
                        onTaskEdit: _onTaskEdit,
                        onTaskDelete: _onTaskDelete,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_showCelebration)
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
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
            ),
        ],
      ),
      // body: Stack(
      //   children: [
      //     ListView(
      //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //       children: [
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Row(
      //               children: [
      //                 Text(
      //                   DateFormat('MMMM yyyy').format(_selectedDate),
      //                   style: const TextStyle(
      //                     fontWeight: FontWeight.bold,
      //                     fontSize: 18,
      //                     fontFamily: 'Inter18'
      //                   ),
      //                 ),
      //                 IconButton(
      //                   icon: const Icon(
      //                     Icons.arrow_drop_down,
      //                     color: Colors.black,
      //                   ),
      //                   onPressed: _pickDate,
      //                 ),
      //               ],
      //             ),
      //             TextButton(
      //               onPressed: () => _onDateSelected(DateTime.now()),
      //               child: const Text(
      //                 'Today',
      //                 style: TextStyle(
      //                   color: Colors.blue,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //         const SizedBox(height: 8),
      //         _buildCalendarBar(),
      //         const SizedBox(height: 16),
      //         Text(
      //           'Tasks for ${DateFormat('MMMM d').format(_selectedDate)}',
      //           style: const TextStyle(
      //             fontWeight: FontWeight.bold,
      //             fontFamily: 'Inter18',
      //             fontSize: 18,
      //           ),
      //         ),
      //         const SizedBox(height: 8),
      //         if (_isLoading)
      //           const Center(child: CircularProgressIndicator())
      //         else if (_tasksForDate.isEmpty)
      //           Padding(
      //             padding: const EdgeInsets.only(top: 40),
      //             child: Center(
      //               child: Column(
      //                 children: [
      //                   Icon(
      //                     Icons.task_alt,
      //                     size: 60,
      //                     color: Colors.grey.withOpacity(0.3),
      //                   ),
      //                   const SizedBox(height: 16),
      //                   const Text(
      //                     'No tasks for this date',
      //                     style: TextStyle(fontSize: 18, color: Colors.grey),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           )
      //         else
      //           ListView.builder(
      //             shrinkWrap: true,
      //             physics: const NeverScrollableScrollPhysics(),
      //             itemCount: _tasksForDate.length,
      //             itemBuilder: (context, index) {
      //               final task = _tasksForDate[index];
      //               return TaskTile(
      //                 task: task,
      //                 onTaskToggle: _onTaskToggle,
      //                 onTaskEdit: _onTaskEdit,
      //                 onTaskDelete: _onTaskDelete,
      //               );
      //             },
      //           ),
      //       ],
      //     ),
      //     if (_showCelebration)
      //       Align(
      //         alignment: Alignment.center,
      //         child: ConfettiWidget(
      //           confettiController: _confettiController,
      //           blastDirectionality: BlastDirectionality.explosive,
      //           blastDirection: -pi / 2,
      //           shouldLoop: false,
      //           colors: const [Colors.green, Colors.blue, Colors.pink],
      //           numberOfParticles: 80,
      //           emissionFrequency: 0.1,
      //           minBlastForce: 15,
      //           maxBlastForce: 30,
      //           gravity: 0.3,
      //         ),
      //       ),
      //   ],
      // ),
    );
  }
}
