import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Enum/RepeatFlag.dart';
import '../models/task.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final void Function({
    required String title,
    String? notes,
    required List<SubTask> subtasks,
    required String priority,
    DateTime? dueDate,
    DateTime? reminderDate,
    bool? reminderEnabled,
    RepeatFlag? repeatFlag,
  })
  onAdd;

  const AddTaskBottomSheet({Key? key, required this.onAdd}) : super(key: key);

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final List<TextEditingController> _subtaskControllers = [];
  String _priority = 'Medium';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _reminderActive = false;
  RepeatFlag _repeatFlag = RepeatFlag.Once;

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    for (var c in _subtaskControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSubtask() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _deleteSubtask(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
    });
  }

  void _cyclePriority() {
    setState(() {
      if (_priority == 'Low') {
        _priority = 'Medium';
      } else if (_priority == 'Medium') {
        _priority = 'High';
      } else {
        _priority = 'Low';
      }
    });
  }

  void _cycleRepeatFlag() {
    setState(() {
      _repeatFlag =
          _repeatFlag == RepeatFlag.Once
              ? RepeatFlag.Daily
              : _repeatFlag == RepeatFlag.Daily
              ? RepeatFlag.Weekly
              : _repeatFlag == RepeatFlag.Weekly
              ? RepeatFlag.Monthly
              : RepeatFlag.Once;
    });
  }

  Future<void> _showReminderPicker() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => _ReminderDialog(
            initialDate: _selectedDate,
            initialTime: _selectedTime,
            initialActive: _reminderActive,
            primaryColor: AppColors.primaryColor,
          ),
    );
    if (result != null) {
      setState(() {
        _selectedDate = result['date'] as DateTime?;
        _selectedTime = result['time'] as TimeOfDay?;
        _reminderActive = result['active'] == true;
      });
    }
  }

  Future<void> _handleAddTask() async {
    final now = DateTime.now();
    final String title = _titleController.text.trim();
    final String description = _notesController.text.trim();
    final List<SubTask> subtasks = List.generate(
      _subtaskControllers.length,
      (i) => SubTask(title: _subtaskControllers[i].text, isCompleted: false),
    );
    final int priority =
        _priority == 'Low'
            ? 1
            : _priority == 'Medium'
            ? 2
            : 3;
    final String taskId = const Uuid().v4();
    final DateTime dueDate =
        _selectedDate ?? DateTime(now.year, now.month, now.day);

    ///Task should not be in past logic
    // if (dueDate.isBefore(DateTime(now.year, now.month, now.day))) {
    //   Get.snackbar('Task Not Added', 'Due date is in the past');
    //   Navigator.pop(context);
    //   return;
    // }
    //
    // if (dueDate.year == now.year &&
    //     dueDate.month == now.month &&
    //     dueDate.day == now.day &&
    //     _selectedTime != null) {
    //   final reminderDateTime = DateTime(
    //     _selectedDate!.year,
    //     _selectedDate!.month,
    //     _selectedDate!.day,
    //     _selectedTime!.hour,
    //     _selectedTime!.minute,
    //   );
    //
    //   if (reminderDateTime.isBefore(now)) {
    //     Get.snackbar('Task Not Added', 'Reminder time is in the past');
    //     Navigator.pop(context);
    //     return;
    //   }
    // }
    DateTime? reminderDateTime;
    if (_selectedDate != null && _selectedTime != null) {
      reminderDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }
    if (_reminderActive && reminderDateTime == null) {
      Get.snackbar(
        'Due Time Required',
        'Due Time is required to set reminder',
      );
      return;
    }
    final task = Task(
      id: taskId,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
      reminder: _reminderActive,
      reminderDate: reminderDateTime,
      subtasks: subtasks,
      repeatFlag: _repeatFlag,
    );
    await _databaseHelper.insertTask(task);
    if (_reminderActive &&
        reminderDateTime != null &&
        reminderDateTime.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: task.id.hashCode,
        title: title,
        body:
            description.isNotEmpty ? description : 'You have a task reminder!',
        scheduledDate: reminderDateTime,
        repeatFlag: _repeatFlag,
      );
    }
    widget.onAdd(
      title: title,
      notes: description,
      subtasks: subtasks,
      priority: _priority,
      dueDate: dueDate,
      reminderDate: reminderDateTime,
      reminderEnabled: _reminderActive,
      repeatFlag: _repeatFlag,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = AppColors.primaryColor;
    final borderColor = Colors.white;
    final maxHeight = MediaQuery.of(context).size.height * 0.95;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomPadding + 16,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFF7F7F7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Center(
                      child: Icon(Icons.close, size: 18, color: Colors.black),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Add new task',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Inter18',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _handleAddTask,
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Color(0xFF6663F1),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter18',
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Title
            // Text('Title', style: TextStyle(fontWeight: FontWeight.w600,fontFamily: 'Inter18',)),
            // const SizedBox(height: 6),
            TextField(
              controller: _titleController,

              style: TextStyle(fontFamily: 'Inter18'),
              decoration: InputDecoration(
                hintText: 'Add title here',
                hintStyle: TextStyle(fontFamily: 'Inter18'),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            // const SizedBox(height: 16),
            // // Description
            // Text('Description', style: TextStyle(fontWeight: FontWeight.w600,fontFamily: 'Inter18',)),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              //maxLines: 3,
              style: TextStyle(fontFamily: 'Inter18'),
              decoration: InputDecoration(
                hintText: 'Add description here(optional) ',
                hintStyle: TextStyle(fontFamily: 'Inter18'),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            // Subtasks
            if (_subtaskControllers.isNotEmpty)
              ...List.generate(_subtaskControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextField(
                    controller: _subtaskControllers[index],
                    style: TextStyle(fontFamily: 'Inter18'),
                    decoration: InputDecoration(
                      hintText: 'Input the sub-task',
                      hintStyle: TextStyle(fontFamily: 'Inter18'),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close, color: theme.iconTheme.color),
                        onPressed: () => _deleteSubtask(index),
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                GestureDetector(
                  onTap: _cyclePriority,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _priority == 'Low'
                              ? Colors.green[50]
                              : _priority == 'Medium'
                              ? Colors.yellow[50]
                              : Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            _priority == 'Low'
                                ? Colors.green
                                : _priority == 'Medium'
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag,
                          color:
                              _priority == 'Low'
                                  ? Colors.green
                                  : _priority == 'Medium'
                                  ? Colors.orange
                                  : Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _priority,
                          style: TextStyle(fontFamily: 'Inter18'),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _cycleRepeatFlag,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.repeat, size: 18, color: Colors.black),
                        const SizedBox(width: 6),
                        Text(
                          repeatFlagToString(_repeatFlag),
                          style: TextStyle(
                            fontFamily: 'Inter18',
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await _showReminderPicker();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _reminderActive ? primaryColor : Colors.grey,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Reminder',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter18',
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: Colors.black,
                          size: 18,
                        ),
                        if (_reminderActive)
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF6663F1),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedDate != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 17,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat(
                              'EEE, MMM d, yyyy',
                            ).format(_selectedDate!),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              fontFamily: 'Inter18',
                            ),
                          ),
                        ],
                      ),
                      if (_selectedTime != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 17,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedTime!.format(context),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                fontFamily: 'Inter18',
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReminderDialog extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final bool initialActive;
  final Color primaryColor;

  const _ReminderDialog({
    Key? key,
    this.initialDate,
    this.initialTime,
    this.initialActive = false,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _reminderActive = false;

  @override
  void initState() {
    super.initState();
    // _selectedDate = widget.initialDate;
    // _selectedTime = widget.initialTime;
    // _reminderActive = widget.initialActive;
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedTime = widget.initialTime;
    _reminderActive = widget.initialActive;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              dialHandColor: widget.primaryColor,
              hourMinuteColor: MaterialStateColor.resolveWith(
                (states) => Colors.white,
              ),
              hourMinuteTextColor: MaterialStateColor.resolveWith(
                (states) => Colors.black,
              ),
              dayPeriodColor: MaterialStateColor.resolveWith(
                (states) =>
                    states.contains(MaterialState.selected)
                        ? widget.primaryColor
                        : Colors.white,
              ),
              dayPeriodTextColor: MaterialStateColor.resolveWith(
                (states) =>
                    states.contains(MaterialState.selected)
                        ? Colors.white
                        : Colors.black,
              ),
              entryModeIconColor: widget.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Set date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, {
                          'date': _selectedDate,
                          'time': _selectedTime,
                          'active': _reminderActive,
                        });
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Calendar
                CalendarDatePicker(
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(DateTime.now().year + 5),
                  onDateChanged: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Add Time and Reminder buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: Icon(Icons.add, color: Color(0xFF6663F1)),
                        label: Text(
                          'Add Time',
                          style: TextStyle(color: Color(0xFF6663F1)),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color(0xFFF3F5F9),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print('the reminder value is $_reminderActive');
                          setState(() {
                            _reminderActive = !_reminderActive;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _reminderActive ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color:
                                  _reminderActive
                                      ? primaryColor
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.alarm,
                                color:
                                    _reminderActive
                                        ? Colors.white
                                        : Colors.black,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Reminder',
                                style: TextStyle(
                                  color:
                                      _reminderActive
                                          ? Colors.white
                                          : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, color: primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          _selectedTime!.format(context),
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
