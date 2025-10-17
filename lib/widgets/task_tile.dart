import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/constants.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(Task) onTaskToggle;
  final Function(Task) onTaskEdit;
  final Function(String) onTaskDelete;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onTaskToggle,
    required this.onTaskEdit,
    required this.onTaskDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      ///working fine 1
        // !task.isCompleted &&
        // task.dueDate != null &&
        // // DateTime(
        // //   task.dueDate!.year,
        // //   task.dueDate!.month,
        // //   task.dueDate!.day,
        // // ).isBefore(today);
        //     (DateTime(
        //       task.dueDate!.year,
        //       task.dueDate!.month,
        //       task.dueDate!.day,
        //     ).isBefore(today) || (task.reminderDate!=null && !task.reminderDate!.isBefore(today)));
    final cardColor = isOverdue ? const Color(0xFFFFDADA) : Color(0xFFE9ECEF);
    final completeButtonColor =
        isOverdue
            ? const Color(0xFFFFDADA)
            : (task.isCompleted ? AppColors.primaryColor : Color(0xFFE9ECEF));
    final completeButtonBorderColor =
        isOverdue ? Colors.red : Color(0xFFDADADA);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Slidable(
        key: ValueKey(task.id),
    startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onTaskToggle(task),
              backgroundColor:
                  task.isCompleted ? AppColors.pending : AppColors.completed,
              foregroundColor: Colors.white,
              icon: task.isCompleted ? Icons.refresh : Icons.check,
              label: task.isCompleted ? 'Undo' : 'Complete',
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
          ],
        ),
        // startActionPane: ActionPane(
        //   motion: const ScrollMotion(),
        //   children: [
        //     if (task.isCompleted)
        //       SlidableAction(
        //         onPressed: (context) => onTaskToggle(task),
        //         backgroundColor: AppColors.primaryColor,
        //         foregroundColor: Colors.white,
        //         icon: Icons.undo,
        //         label: 'Undo',
        //         borderRadius: const BorderRadius.horizontal(
        //           left: Radius.circular(16),
        //         ),
        //       )
        //     else
        //       SlidableAction(
        //         onPressed: (context) => onTaskDelete(task.id),
        //         backgroundColor: Colors.red,
        //         foregroundColor: Colors.white,
        //         icon: Icons.delete,
        //         label: 'Delete',
        //         borderRadius: const BorderRadius.horizontal(
        //           left: Radius.circular(16),
        //         ),
        //       ),
        //   ],
        // ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onTaskDelete(task.id),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(16),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => onTaskEdit(task),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: cardColor,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => onTaskToggle(task),
                      child: Container(
                        width: 24,
                        height: 24,
                        //margin: const EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: completeButtonColor,
                          border: Border.all(
                            color: completeButtonBorderColor,
                            width: 2,
                          ),
                        ),
                        child:
                        task.isCompleted
                            ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Text(
                              task.title,
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                //fontFamily: 'Inter18',
                                decoration:
                                    task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                color:
                                    task.isCompleted
                                        ? AppColors.pending
                                        : AppColors.onSurface,
                              ),
                            ),
                          ),
                          // if (task.description.isNotEmpty)
                          //   const SizedBox(height: 2),
                          //   Text(
                          //     task.description,
                          //     style: TextStyle(
                          //       fontSize: 14,
                          //       fontFamily: 'Inter18',
                          //       color:
                          //           task.isCompleted
                          //               ? AppColors.pending
                          //               : AppColors.onSurface.withOpacity(
                          //                 0.7,
                          //               ),
                          //       decoration:
                          //           task.isCompleted
                          //               ? TextDecoration.lineThrough
                          //               : null,
                          //     ),
                          //   ),
                           const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                              task.dueDate != null
                                  ? MainAxisAlignment.spaceBetween
                                  : MainAxisAlignment.end,
                              children: [
                                if (task.dueDate != null)
                                  Row(
                                    children: [
                                      SvgPicture.asset('assets/icons/calicon.svg',height: 20,width: 20,color: isOverdue?Colors.red:null,),
                                      // const Icon(
                                      //   Icons.calendar_today,
                                      //   size: 14,
                                      //   color: Colors.grey,
                                      // ),
                                      const SizedBox(width: 4),
                                      // Text(
                                      //   DateFormat.yMMMd().format(task.dueDate!),
                                      //   style: const TextStyle(
                                      //     fontFamily: 'Inter',
                                      //     fontSize: 13,
                                      //     color: Colors.grey,
                                      //   ),
                                      // ),
                                      Text(
                                        _formatTaskDateTime(task.dueDate!, task.reminderDate),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          color: isOverdue ?Colors.red:Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppConstants.priorityColors[task.priority],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    AppConstants.priorityLabels[task.priority]!,
                                    style: TextStyle(
                                      fontFamily: 'RobotoCondensed',
                                      color:
                                      AppConstants.priorityLabelsColor[task
                                          .priority]!,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  String _formatTaskDateTime(DateTime dueDate, DateTime? reminderDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    bool isToday = taskDate == today;
    final dateFormatter = DateFormat('d MMM, yyyy');
    final shortDateFormatter = DateFormat('d MMM');
    final timeFormatter = DateFormat('hh:mm a');

    if (isToday && reminderDate != null) {
      return timeFormatter.format(reminderDate);
    } else if (!isToday && reminderDate != null) {
      return '${shortDateFormatter.format(dueDate)}, ${timeFormatter.format(reminderDate)}';
    } else {
      return dateFormatter.format(dueDate);
    }
  }
}
