// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';
// import '../Enum/RepeatFlag.dart';
// import '../models/task.dart';
// import '../utils/constants.dart';
// import '../services/notification_service.dart';
// import '../services/database_helper.dart';
//
// class AddTaskScreen extends StatefulWidget {
//   final Task? task;
//   final String? appBarTitle;
//   final bool isEditing;
//
//   const AddTaskScreen({
//     Key? key,
//     this.task,
//     this.appBarTitle,
//     this.isEditing = false,
//   }) : super(key: key);
//
//   @override
//   State<AddTaskScreen> createState() => _AddTaskScreenState();
// }
//
// class _AddTaskScreenState extends State<AddTaskScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _titleController;
//   late TextEditingController _descriptionController;
//   DateTime? _dueDate;
//   int _priority = AppConstants.mediumPriority;
//   late bool _isEditing;
//   bool _reminder = false;
//   TimeOfDay? _reminderTime;
//   late List<SubTask> _subtasks;
//   RepeatFlag _repeatFlag = RepeatFlag.Once;
//   late RepeatFlag _originalRepeatFlag;
//
//   @override
//   void initState() {
//     super.initState();
//     _isEditing = widget.isEditing;
//     _titleController = TextEditingController(text: widget.task?.title ?? '');
//     _descriptionController = TextEditingController(
//       text: widget.task?.description ?? '',
//     );
//     _dueDate = widget.task?.dueDate;
//     _priority = widget.task?.priority ?? AppConstants.mediumPriority;
//     _reminder = widget.task?.reminder ?? false;
//     _reminderTime =
//         widget.task?.reminderDate != null
//             ? TimeOfDay.fromDateTime(widget.task!.reminderDate!)
//             : null;
//     _subtasks = List<SubTask>.from(widget.task?.subtasks ?? []);
//     _repeatFlag = widget.task?.repeatFlag ?? RepeatFlag.Once;
//     _originalRepeatFlag = widget.task?.repeatFlag ?? RepeatFlag.Once;
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _dueDate ?? DateTime.now(),
//       firstDate: DateTime.now().subtract(const Duration(days: 365)),
//       lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: AppColors.onPrimary,
//               onSurface: AppColors.onSurface,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _dueDate) {
//       setState(() {
//         _dueDate = picked;
//       });
//     }
//   }
//
//   void _clearDueDate() {
//     setState(() {
//       _dueDate = null;
//     });
//   }
//
//   void _saveTask() async {
//     if (_formKey.currentState!.validate()) {
//       DateTime? reminderDateTime;
//       if (_reminderTime != null) {
//         final date = _dueDate ?? DateTime.now();
//         reminderDateTime = DateTime(
//           date.year,
//           date.month,
//           date.day,
//           _reminderTime!.hour,
//           _reminderTime!.minute,
//         );
//       }
//       final bool wasReminder = widget.task?.reminder ?? false;
//       final DateTime? oldReminder = widget.task?.reminderDate;
//       final bool isEditing = _isEditing;
//       final String taskId = isEditing ? widget.task!.id : const Uuid().v4();
//       final task = isEditing
//           ? widget.task!.copyWith(
//         id: taskId,
//         title: _titleController.text,
//         description: _descriptionController.text,
//         dueDate: _dueDate,
//         priority: _priority,
//         isCompleted: widget.task!.isCompleted,
//         reminder: _reminderTime != null,
//         reminderDate: reminderDateTime,
//         subtasks: _subtasks,
//         repeatFlag: _repeatFlag,
//       )
//           : Task(
//         id: taskId,
//         title: _titleController.text,
//         description: _descriptionController.text,
//         createdAt: DateTime.now(),
//         dueDate: _dueDate,
//         priority: _priority,
//         reminder: _reminderTime != null,
//         reminderDate: reminderDateTime,
//         subtasks: _subtasks,
//         repeatFlag: _repeatFlag,
//       );
//       final notificationService = NotificationService();
//       final databaseHelper = DatabaseHelper();
//       String action;
//       if (isEditing) {
//         await databaseHelper.updateTask(task);
//         action = 'updated';
//         if (wasReminder && _reminderTime == null) {
//           await notificationService.cancelNotification(task.id.hashCode);
//         }
//         if (_reminderTime != null && reminderDateTime != null) {
//           bool shouldReschedule = false;
//           if (oldReminder != null && (oldReminder != reminderDateTime || _originalRepeatFlag != _repeatFlag)) {
//             if (oldReminder.isAfter(DateTime.now())) {
//               await notificationService.cancelNotification(task.id.hashCode);
//               shouldReschedule = true;
//             }
//           } else if (oldReminder == null || !wasReminder) {
//             shouldReschedule = true;
//           }
//           if (shouldReschedule && reminderDateTime.isAfter(DateTime.now())) {
//             await notificationService.scheduleNotification(
//               id: task.id.hashCode,
//               title: _titleController.text,
//               body: _descriptionController.text.isNotEmpty
//                   ? _descriptionController.text
//                   : 'You have a task reminder!',
//               scheduledDate: reminderDateTime,
//               repeatFlag: _repeatFlag,
//             );
//           }
//         }
//       } else {
//         await databaseHelper.insertTask(task);
//         action = 'added';
//         if (_reminderTime != null && reminderDateTime != null && reminderDateTime.isAfter(DateTime.now())) {
//           await notificationService.scheduleNotification(
//             id: task.id.hashCode,
//             title: _titleController.text,
//             body: _descriptionController.text.isNotEmpty
//                 ? _descriptionController.text
//                 : 'You have a task reminder!',
//             scheduledDate: reminderDateTime,
//             repeatFlag: _repeatFlag,
//           );
//         }
//       }
//       Navigator.pop(context, {'task': task, 'action': action});
//     }
//   }
//   Future<void> _selectTime(BuildContext context) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: _reminderTime ?? TimeOfDay.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             timePickerTheme: TimePickerThemeData(
//               dialHandColor: AppColors.primaryColor,
//               hourMinuteColor: MaterialStateColor.resolveWith((states) => Colors.white),
//               hourMinuteTextColor: MaterialStateColor.resolveWith((states) => Colors.black),
//               dayPeriodColor: MaterialStateColor.resolveWith(
//                     (states) => states.contains(MaterialState.selected) ? AppColors.primaryColor : Colors.white,
//               ),
//               dayPeriodTextColor: MaterialStateColor.resolveWith(
//                     (states) => states.contains(MaterialState.selected) ? Colors.white : Colors.black,
//               ),
//               entryModeIconColor: AppColors.primaryColor,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() {
//         _reminderTime = picked;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFf7F7F7),
//       appBar: AppBar(
//         backgroundColor: Color(0xFFf7F7F7),
//         centerTitle: false,
//         title: Text(
//           widget.appBarTitle ?? (_isEditing ? 'Edit Task' : 'Add New Task'),
//           style: GoogleFonts.manrope(color: Colors.black,fontSize: 19),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         scrolledUnderElevation: 0,
//         actions: [
//           if (_isEditing)
//             IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder:
//                       (context) => AlertDialog(
//                         title: const Text('Delete Task'),
//                         content: const Text(
//                           'Are you sure you want to delete this task?',
//                         ),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: const Text('CANCEL'),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pop(context); // Close dialog
//                               Navigator.pop(
//                                 context,
//                                 'delete',
//                               ); // Return 'delete' to home screen
//                             },
//                             child: const Text('DELETE'),
//                           ),
//                         ],
//                       ),
//                 );
//               },
//             ),
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Title field
//                   Text(
//                     'Title',
//                     style: GoogleFonts.manrope(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF666666),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextFormField(
//                     controller: _titleController,
//                     style: GoogleFonts.manrope(
//                       fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'Enter task title',
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderSide: const BorderSide(color: Colors.white),
//                         borderRadius: BorderRadius.circular(28),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: const BorderSide(color: Colors.white),
//                         borderRadius: BorderRadius.circular(28),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: const BorderSide(color: Colors.white),
//                         borderRadius: BorderRadius.circular(28),
//                       ),
//                       errorBorder: OutlineInputBorder(
//                         borderSide: const BorderSide(color: Colors.white),
//                         borderRadius: BorderRadius.circular(28),
//                       ),
//                       focusedErrorBorder: OutlineInputBorder(
//                         borderSide: const BorderSide(color: Colors.white),
//                         borderRadius: BorderRadius.circular(28),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter a title';
//                       }
//                       return null;
//                     },
//                     textInputAction: TextInputAction.next,
//                   ),
//                   const SizedBox(height: 15),
//                   // Description field
//                   Text(
//                     'Description (Optional)',
//                     style: GoogleFonts.manrope(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF666666),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextFormField(
//                     controller: _descriptionController,
//                     style: GoogleFonts.manrope(
//                       fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'Enter task description',
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderSide: const BorderSide(color: Colors.white),
//                         borderRadius: BorderRadius.circular(28),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: const BorderSide(color: Colors.white),
//                         borderRadius: BorderRadius.circular(28),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: const BorderSide(color: Colors.white),
//                         borderRadius: BorderRadius.circular(28),
//                       ),
//                       errorBorder: OutlineInputBorder(
//                         borderSide: const BorderSide(color: Colors.white),
//                         borderRadius: BorderRadius.circular(28),
//                       ),
//                       focusedErrorBorder: OutlineInputBorder(
//                         borderSide: const BorderSide(color: Colors.white),
//                         borderRadius: BorderRadius.circular(28),
//                       ),
//                     ),
//                     maxLines: 3,
//                   ),
//                   // Subtasks
//                   if (_subtasks.isNotEmpty) ...[
//                     const SizedBox(height: 24),
//                     Text(
//                       'Subtasks',
//                       style: GoogleFonts.manrope(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xFF666666),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Column(
//                       children: List.generate(_subtasks.length, (i) {
//                         final sub = _subtasks[i];
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 6),
//                           child: Row(
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     _subtasks[i] = SubTask(
//                                       title: sub.title,
//                                       isCompleted: !sub.isCompleted,
//                                     );
//                                   });
//                                 },
//                                 child: Container(
//                                   width: 24,
//                                   height: 24,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: sub.isCompleted ? AppColors.primaryColor : Colors.white,
//                                     border: Border.all(
//                                       color: sub.isCompleted ? AppColors.primaryColor : Colors.grey.shade400,
//                                       width: 2,
//                                     ),
//                                   ),
//                                   child: sub.isCompleted
//                                       ? const Icon(
//                                     Icons.check,
//                                     color: Colors.white,
//                                     size: 16,
//                                   )
//                                       : null,
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   sub.title,
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontFamily: 'Inter18',
//                                     color: sub.isCompleted ? AppColors.primaryColor : Colors.black87,
//                                     decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }),
//                     ),
//                   ],
//                   const SizedBox(height: 15),
//                   // Due date picker
//                   Text(
//                     'Due Date',
//                     style: GoogleFonts.manrope(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF666666),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   InkWell(
//                     onTap: () => _selectDate(context),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//                       child: TextFormField(
//                         style: GoogleFonts.manrope(
//                           fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500,
//                         ),
//                         enabled: false,
//                         decoration: InputDecoration(
//                           hintText: 'Select due date',
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderSide: BorderSide.none,
//                             borderRadius: BorderRadius.circular(28),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderSide: BorderSide.none,
//                             borderRadius: BorderRadius.circular(28),
//                           ),
//                           errorBorder: OutlineInputBorder(
//                             borderSide: BorderSide.none,
//                             borderRadius: BorderRadius.circular(28),
//                           ),
//                           focusedErrorBorder: OutlineInputBorder(
//                             borderSide: BorderSide.none,
//                             borderRadius: BorderRadius.circular(28),
//                           ),
//                         ),
//                         controller: TextEditingController(
//                           text: _dueDate == null ? '' : '${DateFormat.yMMMd().format(_dueDate!)}',
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   // Due time picker
//                   Text(
//                     'Due Time',
//                     style: GoogleFonts.manrope(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF666666),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   InkWell(
//                     onTap: () => _selectTime(context),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//                       child: TextFormField(
//                         enabled: false,
//                         style: GoogleFonts.manrope(
//                           fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: 'Select due time',
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderSide: BorderSide.none,
//                             borderRadius: BorderRadius.circular(28),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderSide: BorderSide.none,
//                             borderRadius: BorderRadius.circular(28),
//                           ),
//                           errorBorder: OutlineInputBorder(
//                             borderSide: BorderSide.none,
//                             borderRadius: BorderRadius.circular(28),
//                           ),
//                           focusedErrorBorder: OutlineInputBorder(
//                             borderSide: BorderSide.none,
//                             borderRadius: BorderRadius.circular(28),
//                           ),
//                         ),
//                         controller: TextEditingController(
//                           text: _reminderTime == null ? '' : _reminderTime!.format(context),
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Task Status section (for editing)
//                   // if (_isEditing) ...[
//                   //   const SizedBox(height: 16),
//                   //   Text(
//                   //     'Task Status',
//                   //     style: GoogleFonts.manrope(
//                   //       fontSize: 16,
//                   //       fontWeight: FontWeight.w500,
//                   //       color: Color(0xFF666666),
//                   //     ),
//                   //   ),
//                   //   const SizedBox(height: 8),
//                   //   Container(
//                   //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                   //     decoration: BoxDecoration(
//                   //       color: Colors.white,
//                   //       borderRadius: BorderRadius.circular(28),
//                   //       border: Border.all(color: Colors.white),
//                   //     ),
//                   //     child: Row(
//                   //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   //       children: [
//                   //         Text(
//                   //           widget.task!.isCompleted ? 'Done' : 'Due',
//                   //           style: GoogleFonts.manrope(
//                   //             color: Colors.black,
//                   //             fontWeight: FontWeight.w500,
//                   //             fontSize: 16,
//                   //           ),
//                   //         ),
//                   //         Transform.scale(
//                   //           scale: 0.8,
//                   //           child: Switch(
//                   //             value: widget.task!.isCompleted,
//                   //             onChanged: null, // Disabled
//                   //             activeColor: AppColors.completed,
//                   //             inactiveThumbColor: Colors.grey,
//                   //           ),
//                   //         ),
//                   //       ],
//                   //     ),
//                   //   ),
//                   // ],
//                   // // Priority section
//                   const SizedBox(height: 16),
//                   Text(
//                     'Priority',
//                     style: GoogleFonts.manrope(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF666666),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       // Low Priority
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _priority = AppConstants.lowPriority;
//                             });
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF3AB67A),
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 if (_priority == AppConstants.lowPriority)
//                                   const Icon(Icons.check, color:  Colors.white, size: 16),
//                                 if (_priority == AppConstants.lowPriority) const SizedBox(width: 6),
//                                 Text(
//                                   'Low',
//                                   style: GoogleFonts.manrope(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       // Medium Priority
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _priority = AppConstants.mediumPriority;
//                             });
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFF7EDD1),
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 if (_priority == AppConstants.mediumPriority)
//                                   const Icon(Icons.check,color: Color(0xFFFFC107), size: 16),
//                                 if (_priority == AppConstants.mediumPriority) const SizedBox(width: 6),
//                                 Text(
//                                   'Medium',
//                                   style: GoogleFonts.manrope(
//                                     color: const Color(0xFFFFC107),
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       // High Priority
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _priority = AppConstants.highPriority;
//                             });
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFF6DDDD),
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 if (_priority == AppConstants.highPriority)
//                                   const Icon(Icons.check, color:  Colors.red, size: 16),
//                                 if (_priority == AppConstants.highPriority) const SizedBox(width: 6),
//                                 Text(
//                                   'High',
//                                   style: GoogleFonts.manrope(
//                                     color: Colors.red,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   // Repeat Flag section
//                   const SizedBox(height: 16),
//                   Text(
//                     'Repeat',
//                     style: GoogleFonts.manrope(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF666666),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: RepeatFlag.values.map((flag) {
//                       final isSelected = _repeatFlag == flag;
//                       return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _repeatFlag = flag;
//                           });
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                           decoration: BoxDecoration(
//                             color: isSelected ? AppColors.primaryColor : const Color(0xFFE9ECEF),
//                             borderRadius: BorderRadius.circular(50),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               if (isSelected)
//                                 const Icon(
//                                   Icons.check,
//                                   color: Colors.white,
//                                   size: 16,
//                                 ),
//                               if (isSelected) const SizedBox(width: 6),
//                               Text(
//                                 repeatFlagToString(flag),
//                                 style: GoogleFonts.manrope(
//                                   color: isSelected ? Colors.white : Colors.black,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 32),
//                   // Save button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: _saveTask,
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                       ),
//                       child: Text(
//                         _isEditing ? 'Update Task' : 'Add Task',
//                         style: TextStyle(fontFamily: 'Inter18'),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../Enum/RepeatFlag.dart';
import '../models/task.dart';
import '../utils/constants.dart';
import '../services/notification_service.dart';
import '../services/database_helper.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  final String? appBarTitle;
  final bool isEditing;

  const AddTaskScreen({
    Key? key,
    this.task,
    this.appBarTitle,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  int _priority = AppConstants.mediumPriority;
  late bool _isEditing;
  bool _reminder = false;
  TimeOfDay? _reminderTime;
  late List<SubTask> _subtasks;
  RepeatFlag _repeatFlag = RepeatFlag.Once;
  late RepeatFlag _originalRepeatFlag;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isEditing;
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _dueDate = widget.task?.dueDate;
    _priority = widget.task?.priority ?? AppConstants.mediumPriority;
    _reminder = widget.task?.reminder ?? false;
    _reminderTime =
    widget.task?.reminderDate != null
        ? TimeOfDay.fromDateTime(widget.task!.reminderDate!)
        : null;
    _subtasks = List<SubTask>.from(widget.task?.subtasks ?? []);
    _repeatFlag = widget.task?.repeatFlag ?? RepeatFlag.Once;
    _originalRepeatFlag = widget.task?.repeatFlag ?? RepeatFlag.Once;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.onPrimary,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _clearDueDate() {
    setState(() {
      _dueDate = null;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              dialHandColor: AppColors.primaryColor,
              hourMinuteColor: MaterialStateColor.resolveWith((states) => Colors.white),
              hourMinuteTextColor: MaterialStateColor.resolveWith((states) => Colors.black),
              dayPeriodColor: MaterialStateColor.resolveWith(
                    (states) => states.contains(MaterialState.selected) ? AppColors.primaryColor : Colors.white,
              ),
              dayPeriodTextColor: MaterialStateColor.resolveWith(
                    (states) => states.contains(MaterialState.selected) ? Colors.white : Colors.black,
              ),
              entryModeIconColor: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
        if (!_reminder) {
          _reminder = true;
        }
      });
    }
  }

  void _saveTask() async {
    if (_reminder && _reminderTime == null) {
      Get.snackbar(
        'Due Time Required','Due Time is required to set reminder'
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      DateTime? reminderDateTime;
      if (_reminder && _reminderTime != null) {
        final date = _dueDate ?? DateTime.now();
        reminderDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _reminderTime!.hour,
          _reminderTime!.minute,
        );
      }
      final bool wasReminder = widget.task?.reminder ?? false;
      final DateTime? oldReminder = widget.task?.reminderDate;
      final bool isEditing = _isEditing;
      final String taskId = isEditing ? widget.task!.id : const Uuid().v4();
      final task = isEditing
          ? widget.task!.copyWith(
        id: taskId,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        priority: _priority,
        isCompleted: widget.task!.isCompleted,
        reminder: _reminder && _reminderTime != null,
        reminderDate: reminderDateTime,
        subtasks: _subtasks,
        repeatFlag: _repeatFlag,
      )
          : Task(
        id: taskId,
        title: _titleController.text,
        description: _descriptionController.text,
        createdAt: DateTime.now(),
        dueDate: _dueDate,
        priority: _priority,
        reminder: _reminder && _reminderTime != null,
        reminderDate: reminderDateTime,
        subtasks: _subtasks,
        repeatFlag: _repeatFlag,
      );
      final notificationService = NotificationService();
      final databaseHelper = DatabaseHelper();
      String action;
      if (isEditing) {
        await databaseHelper.updateTask(task);
        action = 'updated';
        if (wasReminder && (!_reminder || _reminderTime == null)) {
          await notificationService.cancelNotification(task.id.hashCode);
        }
        if (_reminder && _reminderTime != null && reminderDateTime != null) {
          bool shouldReschedule = false;
          if (oldReminder != null && (oldReminder != reminderDateTime || _originalRepeatFlag != _repeatFlag)) {
            if (oldReminder.isAfter(DateTime.now())) {
              await notificationService.cancelNotification(task.id.hashCode);
              shouldReschedule = true;
            }
          } else if (oldReminder == null || !wasReminder) {
            shouldReschedule = true;
          }
          if (shouldReschedule && reminderDateTime.isAfter(DateTime.now())) {
            await notificationService.scheduleNotification(
              id: task.id.hashCode,
              title: _titleController.text,
              body: _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : 'You have a task reminder!',
              scheduledDate: reminderDateTime,
              repeatFlag: _repeatFlag,
            );
          }
        }
      } else {
        await databaseHelper.insertTask(task);
        action = 'added';
        if (_reminder && _reminderTime != null && reminderDateTime != null && reminderDateTime.isAfter(DateTime.now())) {
          await notificationService.scheduleNotification(
            id: task.id.hashCode,
            title: _titleController.text,
            body: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : 'You have a task reminder!',
            scheduledDate: reminderDateTime,
            repeatFlag: _repeatFlag,
          );
        }
      }
      Navigator.pop(context, {'task': task, 'action': action});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf7F7F7),
      appBar: AppBar(
        backgroundColor: Color(0xFFf7F7F7),
        centerTitle: false,
        title: Text(
          widget.appBarTitle ?? (_isEditing ? 'Edit Task' : 'Add New Task'),
          style: GoogleFonts.manrope(color: Colors.black, fontSize: 19),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        scrolledUnderElevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: const Text(
                      'Are you sure you want to delete this task?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(
                            context,
                            'delete',
                          ); // Return 'delete' to home screen
                        },
                        child: const Text('DELETE'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title field
                  Text(
                    'Title',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter task title',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 15),
                  // Description field
                  Text(
                    'Description (Optional)',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter task description',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  // Subtasks
                  if (_subtasks.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Subtasks',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(_subtasks.length, (i) {
                        final sub = _subtasks[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _subtasks[i] = SubTask(
                                      title: sub.title,
                                      isCompleted: !sub.isCompleted,
                                    );
                                  });
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: sub.isCompleted
                                        ? AppColors.primaryColor
                                        : Colors.white,
                                    border: Border.all(
                                      color: sub.isCompleted
                                          ? AppColors.primaryColor
                                          : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: sub.isCompleted
                                      ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  sub.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Inter18',
                                    color: sub.isCompleted
                                        ? AppColors.primaryColor
                                        : Colors.black87,
                                    decoration: sub.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                  const SizedBox(height: 15),
                  // Due date picker
                  Text(
                    'Due Date',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      child: TextFormField(
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: 'Select due date',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        controller: TextEditingController(
                          text: _dueDate == null
                              ? ''
                              : '${DateFormat.yMMMd().format(_dueDate!)}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Reminder checkbox and label in a row
                  // Due time picker
                  Text(
                    'Due Time',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      child: TextFormField(
                        enabled: false,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Select due time',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        controller: TextEditingController(
                          text: _reminderTime == null
                              ? ''
                              : _reminderTime!.format(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reminder',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                      Checkbox(
                        value: _reminder,
                        onChanged: (value) {
                          setState(() {
                            _reminder = value ?? false;
                            if (_reminder && _reminderTime != null) {
                              _reminder = true;
                            }
                          });
                        },
                        activeColor: AppColors.primaryColor,
                        checkColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 10,),
                  // Priority section
                  Text(
                    'Priority',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Low Priority
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _priority = AppConstants.lowPriority;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3AB67A),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_priority == AppConstants.lowPriority)
                                  const Icon(Icons.check,
                                      color: Colors.white, size: 16),
                                if (_priority == AppConstants.lowPriority)
                                  const SizedBox(width: 6),
                                Text(
                                  'Low',
                                  style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Medium Priority
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _priority = AppConstants.mediumPriority;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7EDD1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_priority == AppConstants.mediumPriority)
                                  const Icon(Icons.check,
                                      color: Color(0xFFFFC107), size: 16),
                                if (_priority == AppConstants.mediumPriority)
                                  const SizedBox(width: 6),
                                Text(
                                  'Medium',
                                  style: GoogleFonts.manrope(
                                    color: const Color(0xFFFFC107),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // High Priority
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _priority = AppConstants.highPriority;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6DDDD),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_priority == AppConstants.highPriority)
                                  const Icon(Icons.check,
                                      color: Colors.red, size: 16),
                                if (_priority == AppConstants.highPriority)
                                  const SizedBox(width: 6),
                                Text(
                                  'High',
                                  style: GoogleFonts.manrope(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Repeat Flag section
                  const SizedBox(height: 16),
                  Text(
                    'Repeat',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: RepeatFlag.values.map((flag) {
                      final isSelected = _repeatFlag == flag;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _repeatFlag = flag;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor
                                : const Color(0xFFE9ECEF),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              if (isSelected) const SizedBox(width: 6),
                              Text(
                                repeatFlagToString(flag),
                                style: GoogleFonts.manrope(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'Update Task' : 'Add Task',
                        style: TextStyle(fontFamily: 'Inter18'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}