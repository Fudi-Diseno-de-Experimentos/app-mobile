/// Shared date formatting for UI surfaces. Every helper takes an ISO-8601
/// string and falls back to returning the raw input when it cannot be parsed.
class AppDateFormat {
  AppDateFormat._();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// `Today` / `Yesterday` / `d/m/yyyy` — created-at timestamps on cards,
  /// detail pages and comments.
  static String relativeDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0 && now.day == date.day) return 'Today';
      if (diff.inDays <= 1) return 'Yesterday';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  /// `dd/mm/yyyy, h:mm AM` — event schedule on the detail page.
  static String dateTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month/${date.year}, ${_clock(date)}';
    } catch (_) {
      return isoDate;
    }
  }

  /// `Today, h:mm PM` / `m/d/yyyy, h:mm PM` — event cards.
  static String relativeDateTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return 'Today, ${_clock(date)}';
      }
      return '${date.month}/${date.day}/${date.year}, ${_clock(date)}';
    } catch (_) {
      return isoDate;
    }
  }

  /// `Jan 05, h:mm PM` (local time) — analytics history rows.
  static String monthDayTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      return '${_months[date.month - 1]} $day, ${_clock(date)}';
    } catch (_) {
      return isoDate;
    }
  }

  /// `dd/mm/yyyy` (local time).
  static String date(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  static String _clock(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
