import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/AdService.dart';
import '../services/database_helper.dart';
import '../models/task.dart';
import '../utils/NativeAdWidget.dart';
import '../utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/activity.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

// Helper for string to map (since jsonDecode can't handle single quotes)
dynamic eval(String s) {
  return s.contains("'") ? jsonDecode(s.replaceAll("'", '"')) : jsonDecode(s);
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Task> _tasks = [];
  int _selectedTab = 0; // 0: Week, 1: Month, 2: Year
  bool _isLoading = true;
  final AdService adService = Get.find<AdService>();

  // --- Recent Activity State ---
  List<Activity> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    adService.loadAnalyticsScreenBannerAd();
    _loadTasks();
    _loadRecentActivities();
    _checkAndRecordMissedTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await _dbHelper.getTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  void _loadRecentActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = RecentActivityHelper.todayKeyString();
    final List<String> list = prefs.getStringList(todayKey) ?? [];
    List<Activity> activities =
        list.map((s) => RecentActivityHelper.decodeActivity(s)).toList();
    // Add missed/completed/added for today from _tasks (legacy)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final t in _tasks) {
      // Added today
      if (t.createdAt.isAfter(today)) {
        activities.add(
          Activity(type: ActivityType.added, task: t, time: t.createdAt),
        );
      }
      // Missed (due date passed and not completed)
      if (t.dueDate != null &&
          !t.isCompleted &&
          t.dueDate!.isBefore(now) &&
          t.dueDate!.isAfter(today)) {
        activities.add(
          Activity(type: ActivityType.missed, task: t, time: t.dueDate!),
        );
      }
      // Completed today
      if (t.isCompleted && t.dueDate != null && t.dueDate!.isAfter(today)) {
        activities.add(
          Activity(type: ActivityType.completed, task: t, time: t.dueDate!),
        );
      }
    }
    activities.sort((a, b) => b.time.compareTo(a.time));
    setState(() {
      _recentActivities = activities;
    });
  }

  Future<void> _checkAndRecordMissedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = RecentActivityHelper.todayKeyString();
    final List<String> list = prefs.getStringList(todayKey) ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final t in _tasks) {
      if (t.dueDate != null &&
          !t.isCompleted &&
          t.dueDate!.isBefore(now) &&
          t.dueDate!.isAfter(today)) {
        // Check if already recorded
        final alreadyRecorded = list.any((s) {
          final a = RecentActivityHelper.decodeActivity(s);
          return a.type == ActivityType.missed && a.task.id == t.id;
        });
        if (!alreadyRecorded) {
          await RecentActivityHelper.recordActivity(
            Activity(type: ActivityType.missed, task: t, time: t.dueDate!),
          );
        }
      }
    }
  }

  DateTime get _periodStart {
    final now = DateTime.now();
    if (_selectedTab == 0) {
      return now.subtract(Duration(days: now.weekday - 1));
    } else if (_selectedTab == 1) {
      return DateTime(now.year, now.month, 1);
    } else {
      return DateTime(now.year, 1, 1);
    }
  }

  List<Task> get _filteredTasks {
    final start = _periodStart;
    return _tasks
        .where(
          (t) => t.createdAt.isAfter(start.subtract(const Duration(days: 1))),
        )
        .toList();
  }

  int get _completedCount => _filteredTasks.where((t) => t.isCompleted).length;
  int get _inProgressCount =>
      _filteredTasks.where((t) => !t.isCompleted).length;
  int get _totalCount => _filteredTasks.length;
  double get _completionRate =>
      _totalCount == 0 ? 0 : (_completedCount / _totalCount) * 100;
  // int get _productivityScore =>
  //     _completedCount * 5 +
  //     (_selectedTab == 0
  //         ? 2
  //         : _selectedTab == 1
  //         ? 1
  //         : 0);
  int get _productivityScore => _filteredTasks.where((t) => t.isCompleted).length;

  String get _completionRateChange => '+12%';
  String get _productivityChange => '+5%';
  String get _inProgressChange => '-3';

  // --- Chart Data Helpers ---
  List<String> get _chartLabels {
    if (_selectedTab == 0) {
      // Week: Mon-Sun
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (_selectedTab == 1) {
      // Month: 1-30/31
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      return List.generate(daysInMonth, (i) => '${i + 1}');
    } else {
      // Year: Jan-Dec
      return [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
    }
  }

  List<double> get _completionRatesPerPeriod {
    final labels = _chartLabels;
    List<double> rates = [];
    for (int i = 0; i < labels.length; i++) {
      int completed = 0;
      int total = 0;
      for (final t in _filteredTasks) {
        DateTime created = t.createdAt;
        if (_selectedTab == 0) {
          // Week: group by weekday
          if (created.weekday == i + 1) {
            total++;
            if (t.isCompleted) completed++;
          }
        } else if (_selectedTab == 1) {
          // Month: group by day
          if (created.day == i + 1) {
            total++;
            if (t.isCompleted) completed++;
          }
        } else {
          // Year: group by month
          if (created.month == i + 1) {
            total++;
            if (t.isCompleted) completed++;
          }
        }
      }
      rates.add(total == 0 ? 0 : (completed / total) * 100);
    }
    return rates;
  }

  Map<String, int> get _priorityCounts {
    int high = 0, medium = 0, low = 0;
    for (final t in _filteredTasks) {
      if (t.priority == 3)
        high++;
      else if (t.priority == 2)
        medium++;
      else if (t.priority == 1)
        low++;
      // else ignore unknown priorities
    }
    return {'High': high, 'Medium': medium, 'Low': low};
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          'Analytics',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.055,
            fontFamily: 'Inter18'
          ),
        ),
        centerTitle: false,
        // actions: [
        //   Padding(
        //     padding: EdgeInsets.only(right: screenWidth * 0.03),
        //     child: GestureDetector(
        //       onTap: (){
        //         Get.toNamed('/premium', arguments: {'fromNamed': false});
        //       },
        //       child: Row(
        //         children: [
        //           Text(
        //             'Upgrade',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontWeight: FontWeight.bold,
        //               fontSize: screenWidth * 0.0425,
        //               fontFamily: 'Inter18'
        //             ),
        //           ),
        //           SizedBox(width: screenWidth * 0.02),
        //           SvgPicture.asset(
        //             'assets/icons/premium.svg',
        //             height: screenHeight * 0.028,
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    child: Row(
                      children: [
                        _buildTabButton('Week', 0, screenWidth, screenHeight),
                        SizedBox(width: screenWidth * 0.02),
                        _buildTabButton('Month', 1, screenWidth, screenHeight),
                        SizedBox(width: screenWidth * 0.02),
                        _buildTabButton('Year', 2, screenWidth, screenHeight),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            crossAxisSpacing: screenWidth * 0.03,
                            mainAxisSpacing: screenHeight * 0.02,
                            childAspectRatio: 1.2,
                            children: [
                              _buildStatCard(
                                icon: Icons.check_circle,
                                iconBg: const Color(0xFFE6F7E6),
                                iconColor: const Color(0xFF4CAF50),
                                value: '$_completedCount',
                                label: 'Tasks Completed',
                                subLabel:
                                    'This  ${_selectedTab == 0
                                        ? 'week'
                                        : _selectedTab == 1
                                        ? 'month'
                                        : 'year'}',
                              ),
                              _buildStatCard(
                                icon: Icons.percent,
                                iconBg: const Color(0xFFE6F0FA),
                                iconColor: const Color(0xFF2196F3),
                                value: '${_completionRate.toStringAsFixed(0)}%',
                                label: 'Completion Rate',
                                subLabel: _completionRateChange,
                                subLabelColor: const Color(0xFF2196F3),
                              ),
                              _buildStatCard(
                                icon: Icons.timer,
                                iconBg: const Color(0xFFFFF7E6),
                                iconColor: const Color(0xFFFFB800),
                                value: '$_productivityScore',
                                label: 'Productivity Score',
                                subLabel: _productivityChange,
                                subLabelColor: const Color(0xFFFFB800),
                              ),
                              _buildStatCard(
                                icon: Icons.access_time,
                                iconBg: const Color(0xFFFFE6E6),
                                iconColor: const Color(0xFFFF5252),
                                value: '$_inProgressCount',
                                label: 'Tasks In Progress',
                                subLabel: _inProgressChange,
                                subLabelColor: const Color(0xFFFF5252),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Obx(() {
                            return adService.showBannerAd(
                              adService.isBannerAnalyticAdLoaded.value,
                              adService.bannerAdForFraming,
                            );
                          }),
                          SizedBox(height: 12),
                          _buildCompletionRateChart(context),
                          SizedBox(height: 24),
                          _buildTaskDistributionChart(context),
                          SizedBox(height: 24),
                          _buildRecentActivitySection(),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildTabButton(
    String label,
    int index,
    double screenWidth,
    double screenHeight,
  ) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color(0xFF2196F3).withOpacity(0.15)
                    : Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.065),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter18',
              fontSize: screenWidth * 0.037,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
    String? subLabel,
    Color? subLabelColor,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.06),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.015,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Icon(icon, color: iconColor, size: screenWidth * 0.06),
              ),
              if (subLabel != null)
                Text(
                  subLabel,
                  style: TextStyle(
                    color: subLabelColor ?? Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.02),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.06,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.02),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCompletionRateChart(BuildContext context) {
    final rates = _completionRatesPerPeriod;
    final labels = _chartLabels;
    final hasData = rates.any((r) => r > 0);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Completion Rate',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                  fontFamily: 'Inter18'
                ),
              ),
              const Spacer(),
              if (hasData)
                Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.green,
                      size: screenWidth * 0.035,
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      '12% vs last week',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: screenWidth * 0.033,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          SizedBox(
            height: screenHeight * 0.2,
            child: hasData
                ? LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: screenWidth * 0.08,
                      getTitlesWidget: (value, meta) {
                        if (value % 20 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: screenWidth * 0.03),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (labels.length / 6).ceilToDouble(),
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) {
                          return Container();
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.01),
                          child: Text(
                            labels[idx],
                            style: TextStyle(fontSize: screenWidth * 0.027),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      rates.length,
                          (i) => FlSpot(i.toDouble(), rates[i]),
                    ),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: screenWidth * 0.008,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            )
                : Center(
              child: Text(
                'No data to display',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCompletionRateChart() {
  //   final rates = _completionRatesPerPeriod;
  //   final labels = _chartLabels;
  //   final hasData = rates.any((r) => r > 0);
  //
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 16),
  //     padding: EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(24),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Text(
  //               'Completion Rate',
  //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  //             ),
  //             Spacer(),
  //             if (hasData)
  //               Row(
  //                 children: [
  //                   Icon(Icons.arrow_upward, color: Colors.green, size: 16),
  //                   Text(
  //                     ' 12% vs last week',
  //                     style: TextStyle(color: Colors.green, fontSize: 13),
  //                   ),
  //                 ],
  //               ),
  //           ],
  //         ),
  //         SizedBox(height: 12),
  //         SizedBox(
  //           height: 160,
  //           child:
  //               hasData
  //                   ? LineChart(
  //                     LineChartData(
  //                       minY: 0,
  //                       maxY: 100,
  //                       gridData: FlGridData(
  //                         show: true,
  //                         horizontalInterval: 20,
  //                       ),
  //                       titlesData: FlTitlesData(
  //                         leftTitles: AxisTitles(
  //                           sideTitles: SideTitles(
  //                             showTitles: true,
  //                             interval: 20,
  //                             reservedSize: 32,
  //                             getTitlesWidget: (value, meta) {
  //                               if (value % 20 == 0) {
  //                                 return Text(
  //                                   value.toInt().toString(),
  //                                   style: TextStyle(fontSize: 12),
  //                                 );
  //                               }
  //                               return Container();
  //                             },
  //                           ),
  //                         ),
  //                         bottomTitles: AxisTitles(
  //                           sideTitles: SideTitles(
  //                             showTitles: true,
  //                             getTitlesWidget: (value, meta) {
  //                               int idx = value.toInt();
  //                               if (idx < 0 || idx >= labels.length)
  //                                 return Container();
  //                               return Text(
  //                                 labels[idx],
  //                                 style: TextStyle(fontSize: 11),
  //                               );
  //                             },
  //                             interval: (labels.length / 6).ceilToDouble(),
  //                           ),
  //                         ),
  //                         rightTitles: AxisTitles(
  //                           sideTitles: SideTitles(showTitles: false),
  //                         ),
  //                         topTitles: AxisTitles(
  //                           sideTitles: SideTitles(showTitles: false),
  //                         ),
  //                       ),
  //                       borderData: FlBorderData(show: false),
  //                       lineBarsData: [
  //                         LineChartBarData(
  //                           spots: List.generate(
  //                             rates.length,
  //                             (i) => FlSpot(i.toDouble(), rates[i]),
  //                           ),
  //                           isCurved: true,
  //                           color: Colors.green,
  //                           barWidth: 3,
  //                           dotData: FlDotData(show: true),
  //                           belowBarData: BarAreaData(
  //                             show: true,
  //                             color: Colors.green.withOpacity(0.15),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   )
  //                   : Center(
  //                     child: Text(
  //                       'No data to display',
  //                       style: TextStyle(color: Colors.grey),
  //                     ),
  //                   ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildTaskDistributionChart(BuildContext context) {
    final counts = _priorityCounts;
    final total = counts.values.fold(0, (a, b) => a + b);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Distribution',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.045,
                fontFamily: 'Inter18'
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          total == 0
              ? Center(
            child: Text(
              'No tasks to display',
              style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035),
            ),
          )
              : Row(
            children: [
              SizedBox(
                width: screenWidth * 0.22,
                height: screenWidth * 0.22,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: Colors.redAccent,
                        value: counts['High']!.toDouble(),
                        title: '',
                        radius: screenWidth * 0.055,
                      ),
                      PieChartSectionData(
                        color: Colors.orangeAccent,
                        value: counts['Medium']!.toDouble(),
                        title: '',
                        radius: screenWidth * 0.055,
                      ),
                      PieChartSectionData(
                        color: Colors.green,
                        value: counts['Low']!.toDouble(),
                        title: '',
                        radius: screenWidth * 0.055,
                      ),
                    ],
                    centerSpaceRadius: screenWidth * 0.07,
                    sectionsSpace: screenWidth * 0.005,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.045),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegend(context, 'High Priority', counts['High']!, total, Colors.redAccent),
                    SizedBox(height: screenHeight * 0.01),
                    _buildLegend(context, 'Medium Priority', counts['Medium']!, total, Colors.orangeAccent),
                    SizedBox(height: screenHeight * 0.01),
                    _buildLegend(context, 'Low Priority', counts['Low']!, total, Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, String label, int count, int total, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double percent = total == 0 ? 0 : count / total;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: screenWidth * 0.03,
                height: screenWidth * 0.03,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: screenWidth * 0.015),
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$count tasks (${(percent * 100).toStringAsFixed(0)}%)',
                style: TextStyle(
                  fontSize: screenWidth * 0.032,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.006),
          ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: screenHeight * 0.008,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildTaskDistributionChart() {
  //   final counts = _priorityCounts;
  //   final total = counts.values.fold(0, (a, b) => a + b);
  //
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 16),
  //     padding: EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(24),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Task Distribution',
  //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  //         ),
  //         SizedBox(height: 12),
  //         total == 0
  //             ? Center(
  //               child: Text(
  //                 'No tasks to display',
  //                 style: TextStyle(color: Colors.grey),
  //               ),
  //             )
  //             : Row(
  //               children: [
  //                 SizedBox(
  //                   width: 90,
  //                   height: 90,
  //                   child: PieChart(
  //                     PieChartData(
  //                       sections: [
  //                         PieChartSectionData(
  //                           color: Colors.redAccent,
  //                           value: counts['High']!.toDouble(),
  //                           title: '',
  //                           radius: 22,
  //                         ),
  //                         PieChartSectionData(
  //                           color: Colors.orangeAccent,
  //                           value: counts['Medium']!.toDouble(),
  //                           title: '',
  //                           radius: 22,
  //                         ),
  //                         PieChartSectionData(
  //                           color: Colors.green,
  //                           value: counts['Low']!.toDouble(),
  //                           title: '',
  //                           radius: 22,
  //                         ),
  //                       ],
  //                       centerSpaceRadius: 28,
  //                       sectionsSpace: 2,
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 18),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       _buildLegend(
  //                         'High Priority',
  //                         counts['High']!,
  //                         total,
  //                         Colors.redAccent,
  //                       ),
  //                       SizedBox(height: 8),
  //                       _buildLegend(
  //                         'Medium Priority',
  //                         counts['Medium']!,
  //                         total,
  //                         Colors.orangeAccent,
  //                       ),
  //                       SizedBox(height: 8),
  //                       _buildLegend(
  //                         'Low Priority',
  //                         counts['Low']!,
  //                         total,
  //                         Colors.green,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildRecentActivitySection() {
    final activities = _recentActivities;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,fontFamily: 'Inter18'),
          ),
          SizedBox(height: 12),
          if (activities.isEmpty)
            Center(
              child: Text(
                'No recent activity',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (_, __) => SizedBox(height: 10),
              itemBuilder: (context, i) {
                final a = activities[i];
                return _buildActivityTile(a);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(Activity a) {
    final task = a.task;
    final isCompleted = a.type == ActivityType.completed;
    final isMissed = a.type == ActivityType.missed;
    final isEdited = a.type == ActivityType.edited;
    final isDeleted = a.type == ActivityType.deleted;
    Color color;
    if (isMissed) {
      color = Colors.red;
    } else if (isCompleted) {
      color = Colors.green;
    } else if (isEdited) {
      color = Colors.blueAccent;
    } else if (isDeleted) {
      color = Colors.grey;
    } else {
      color = Colors.green;
    }
    final statusDot = Container(
      width: 10,
      height: 10,
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    String activityText;
    if (isCompleted) {
      activityText = 'Completed "${task.title}"';
    } else if (isMissed) {
      activityText = 'Missed "${task.title}"';
    } else if (isEdited) {
      activityText = 'Edited "${task.title}"';
    } else if (isDeleted) {
      activityText = 'Deleted "${task.title}"';
    } else {
      activityText = 'Added "${task.title}"';
    }
    String timeText = _formatTime(a.time);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            statusDot,
            Expanded(child: Text(activityText, style: TextStyle(fontSize: 15))),
            _buildPriorityChip(task.priority),
          ],
        ),
        SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 18), // 10 (dot) + 8 (margin)
          child: Text(
            timeText,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityChip(int priority) {
    String text;
    Color color;
    switch (priority) {
      case 3:
        text = 'High';
        color = Colors.redAccent;
        break;
      case 2:
        text = 'Medium';
        color = Colors.orangeAccent;
        break;
      default:
        text = 'Low';
        color = Colors.green;
    }
    return Container(
      margin: EdgeInsets.only(left: 8, top: 2),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    if (time.isAfter(today)) {
      return 'Today, ${DateFormat.jm().format(time)}';
    } else if (time.isAfter(yesterday)) {
      return 'Yesterday, ${DateFormat.jm().format(time)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(time);
    }
  }

  // Widget _buildLegend(String label, int count, int total, Color color) {
  //   double percent = total == 0 ? 0 : count / total;
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               width: 12,
  //               height: 12,
  //               decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  //             ),
  //             SizedBox(width: 6),
  //             Text(
  //               label,
  //               style: TextStyle(
  //                 fontSize: 11, // Smaller font size
  //                 color: color,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             Spacer(),
  //             Text(
  //               '$count tasks (${(percent * 100).toStringAsFixed(0)}%)',
  //               style: TextStyle(fontSize: 12, color: Colors.grey[700]),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 6),
  //         ClipRRect(
  //           borderRadius: BorderRadius.circular(8), // Rounded corners
  //           child: LinearProgressIndicator(
  //             value: percent,
  //             backgroundColor: color.withOpacity(0.15),
  //             valueColor: AlwaysStoppedAnimation<Color>(color),
  //             minHeight: 6,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
