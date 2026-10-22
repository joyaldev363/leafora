/// Dedicated date and time helper functions tailored for plant care scheduling.
abstract final class DateTimeUtils {
  /// Checks whether two [DateTime] instances occur on the exact same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Determines whether [date] is today.
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Determines whether [date] is tomorrow.
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  /// Calculates the next care date by adding [intervalDays] to [fromDate].
  static DateTime calculateNextCareDate({
    DateTime? fromDate,
    required int intervalDays,
  }) {
    final base = fromDate ?? DateTime.now();
    return base.add(Duration(days: intervalDays));
  }

  /// Returns a human-friendly relative care label (e.g. "Due Today", "Tomorrow", "In 4 days", "Overdue").
  static String formatCareDueLabel(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);

    final differenceInDays = due.difference(today).inDays;

    if (differenceInDays < 0) {
      final days = differenceInDays.abs();
      return days == 1 ? 'Overdue by 1 day' : 'Overdue by $days days';
    } else if (differenceInDays == 0) {
      return 'Due today';
    } else if (differenceInDays == 1) {
      return 'Due tomorrow';
    } else {
      return 'In $differenceInDays days';
    }
  }

  /// Formats a time into a clean 12-hour string (e.g. "09:00 AM").
  static String formatTimeOfDay(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0
        ? 12
        : hour > 12
        ? hour - 12
        : hour;
    return '$formattedHour:$minute $period';
  }
}
