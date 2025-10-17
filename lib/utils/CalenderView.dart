// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
//
// class CalendarView extends StatefulWidget {
//   final Function(DateTime) onDateSelected;
//   const CalendarView({super.key,required this.onDateSelected});
//
//   @override
//   State<CalendarView> createState() => _CalendarViewState();
// }
//
// class _CalendarViewState extends State<CalendarView> {
//   DateTime _selectedDate = DateTime.now();
//
//   void _goToPreviousMonth() {
//     setState(() {
//       _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
//     });
//   }
//
//   void _goToNextMonth() {
//     setState(() {
//       _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
//     });
//   }
//
//   // List<Widget> _buildCalendarGrid() {
//   //   final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
//   //   final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
//   //   final firstWeekday = firstDayOfMonth.weekday % 7;
//   //   final totalDays = lastDayOfMonth.day;
//   //   final dayCells = <Widget>[];
//   //   for (int i = 0; i < firstWeekday; i++) {
//   //     dayCells.add(const SizedBox());
//   //   }
//   //   for (int day = 1; day <= totalDays; day++) {
//   //     final dayDate = DateTime(_selectedDate.year, _selectedDate.month, day);
//   //     final isToday = DateTime.now().year == dayDate.year &&
//   //         DateTime.now().month == dayDate.month &&
//   //         DateTime.now().day == dayDate.day;
//   //
//   //     dayCells.add(
//   //       GestureDetector(
//   //         onTap: () {
//   //           setState(() {
//   //             _selectedDate = dayDate;
//   //           });
//   //           widget.onDateSelected(dayDate);
//   //         },
//   //         child: Container(
//   //           decoration: BoxDecoration(
//   //             color: isToday ? Color(0xFF6663F1) : Colors.transparent,
//   //             shape: BoxShape.circle,
//   //           ),
//   //           alignment: Alignment.center,
//   //           margin: const EdgeInsets.all(4),
//   //           child: Text(
//   //             '$day',
//   //             style: GoogleFonts.manrope(
//   //               fontSize: 15,
//   //               color: isToday ? Colors.white : Colors.black,
//   //               fontWeight: FontWeight.w500
//   //             ),
//   //           ),
//   //         ),
//   //       ),
//   //     );
//   //   }
//   //   return dayCells;
//   // }
//   List<Widget> _buildCalendarGrid() {
//     final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
//     final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
//     final firstWeekday = firstDayOfMonth.weekday % 7;
//     final totalDays = lastDayOfMonth.day;
//     final dayCells = <Widget>[];
//
//     for (int i = 0; i < firstWeekday; i++) {
//       dayCells.add(const SizedBox());
//     }
//
//     for (int day = 1; day <= totalDays; day++) {
//       final dayDate = DateTime(_selectedDate.year, _selectedDate.month, day);
//       final isSelected = _selectedDate.year == dayDate.year &&
//           _selectedDate.month == dayDate.month &&
//           _selectedDate.day == dayDate.day;
//
//       dayCells.add(
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               _selectedDate = dayDate;
//             });
//             widget.onDateSelected(dayDate);
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: isSelected ? const Color(0xFF6663F1) : Colors.transparent,
//               shape: BoxShape.circle,
//             ),
//             alignment: Alignment.center,
//             margin: const EdgeInsets.all(4),
//             child: Text(
//               '$day',
//               style: GoogleFonts.manrope(
//                 fontSize: 15,
//                 color: isSelected ? Colors.white : Colors.black,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     return dayCells;
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE9ECEF),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           /// Top row with arrows and month name
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.chevron_left),
//                 onPressed: _goToPreviousMonth,
//               ),
//               Text(
//                 DateFormat('MMMM yyyy').format(_selectedDate),
//                 style: GoogleFonts.manrope(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF5D5E60)
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.chevron_right),
//                 onPressed: _goToNextMonth,
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 8),
//
//           /// Weekday labels
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
//                 .map((day) => Expanded(
//               child: Center(
//                 child: Text(
//                   day,
//                   style: GoogleFonts.manrope(
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF5D5E60)
//                   ),
//                 ),
//               ),
//             ))
//                 .toList(),
//           ),
//
//           const SizedBox(height: 8),
//
//           /// Calendar day grid
//           GridView.count(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             crossAxisCount: 7,
//             mainAxisSpacing: 0,
//             childAspectRatio: 1.4,
//             children: _buildCalendarGrid(),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CalendarView extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const CalendarView({Key? key, required this.onDateSelected})
    : super(key: key);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _selectedDate = DateTime.now();
  DateTime _visibleMonthDate = DateTime.now();

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonthDate = DateTime(
        _visibleMonthDate.year,
        _visibleMonthDate.month - 1,
      );
    });
  }

  void _goToNextMonth() {
    setState(() {
      _visibleMonthDate = DateTime(
        _visibleMonthDate.year,
        _visibleMonthDate.month + 1,
      );
    });
  }

  void _onDateTapped(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected(date);
  }

  List<Widget> _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _visibleMonthDate.year,
      _visibleMonthDate.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _visibleMonthDate.year,
      _visibleMonthDate.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;
    final dayCells = <Widget>[];

    for (int i = 0; i < firstWeekday; i++) {
      dayCells.add(const SizedBox());
    }

    for (int day = 1; day <= totalDays; day++) {
      final dayDate = DateTime(
        _visibleMonthDate.year,
        _visibleMonthDate.month,
        day,
      );
      final isSelected =
          _selectedDate.year == dayDate.year &&
          _selectedDate.month == dayDate.month &&
          _selectedDate.day == dayDate.day;

      dayCells.add(
        GestureDetector(
          onTap: () => _onDateTapped(dayDate),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6663F1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4),
            child: Text(
              '$day',
              style: GoogleFonts.manrope(
                fontSize: 15,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return dayCells;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(16),),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _goToPreviousMonth,
              ),
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D5E60),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _goToNextMonth,
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Weekday labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D5E60),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),

          const SizedBox(height: 8),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 7,
            mainAxisSpacing: 0,
            childAspectRatio: 1.4,
            children: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }
}
