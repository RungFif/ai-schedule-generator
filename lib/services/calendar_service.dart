import 'package:add_2_calendar/add_2_calendar.dart';

class CalendarService {
  /// Add tasks to the native calendar app.
  ///
  /// `tasks` is a list of maps with keys: `name` (String), `duration` (int minutes),
  /// and `priority` (String). Tasks are scheduled sequentially starting at 08:00
  /// local time (or the provided `startDate`). Priority ordering: Tinggi/High,
  /// Sedang/Medium, Rendah/Low.
  static Future<void> addTasksToCalendar(
    List<Map<String, dynamic>> tasks, {
    DateTime? startDate,
  }) async {
    final priorityOrder = <String, int>{
      'Tinggi': 0,
      'High': 0,
      'Sedang': 1,
      'Medium': 1,
      'Rendah': 2,
      'Low': 2,
    };

    // Sort tasks by priority (stable for same-priority order)
    tasks.sort((a, b) {
      final pa = priorityOrder[a['priority']] ?? 1;
      final pb = priorityOrder[b['priority']] ?? 1;
      return pa.compareTo(pb);
    });

    var now = startDate ?? DateTime.now();
    var current = DateTime(now.year, now.month, now.day, 8, 0);

    for (final task in tasks) {
      final name = task['name']?.toString() ?? 'Untitled Task';
      final priority = task['priority']?.toString() ?? '';
      final durationMinutes = task['duration'] is int
          ? task['duration'] as int
          : int.tryParse(task['duration']?.toString() ?? '') ?? 30;

      final start = current;
      final end = current.add(Duration(minutes: durationMinutes));

      final event = Event(
        title: name,
        description: 'Priority: $priority',
        location: '',
        startDate: start,
        endDate: end,
      );

      // Open native calendar UI to add the event (user confirmation required).
      await Add2Calendar.addEvent2Cal(event);

      current = end; // next task starts after this one
    }
  }
}
