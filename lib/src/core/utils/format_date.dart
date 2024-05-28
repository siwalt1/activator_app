import 'package:intl/intl.dart';


String formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    // Same day, show time (e.g., 10:15)
    return DateFormat.Hm().format(date);
  } else if (difference.inDays == 1) {
    // Yesterday
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    // Within the last week, show weekday (e.g., Sunday)
    return DateFormat.EEEE().format(date);
  } else if (difference.inDays < 365) {
    // Within the same year, show day and month (e.g., 20.05)
    return DateFormat.MMMd().format(date);
  } else {
    // Older than a year, show full date (e.g., 20.05.24)
    return DateFormat.yMd().format(date);
  }
}
