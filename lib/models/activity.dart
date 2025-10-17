import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'task.dart';

enum ActivityType { added, completed, missed, edited, deleted }

class Activity {
  final ActivityType type;
  final Task task;
  final DateTime time;
  Activity({required this.type, required this.task, required this.time});

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'task': task.toMap(),
    'time': time.toIso8601String(),
  };

  static Activity fromJson(Map<String, dynamic> json) {
    return Activity(
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      task: Task.fromMap(json['task']),
      time: DateTime.parse(json['time']),
    );
  }
}

class RecentActivityHelper {
  static Future<void> recordActivity(Activity activity) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = todayKeyString();
    final List<String> list = prefs.getStringList(todayKey) ?? [];
    list.add(encodeActivity(activity));
    await prefs.setStringList(todayKey, list);
  }

  static String todayKeyString() {
    final now = DateTime.now();
    return 'recent_activities_${now.year}_${now.month}_${now.day}';
  }

  static String encodeActivity(Activity a) => jsonEncode(a.toJson());
  static Activity decodeActivity(String s) => Activity.fromJson(jsonDecode(s));
}
