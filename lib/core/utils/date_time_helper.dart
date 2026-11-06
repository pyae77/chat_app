class DatetimeHelper {
  static String formatTimeOnly(DateTime timestamp) {
    final hour = timestamp.hour > 12
        ? timestamp.hour - 12
        : (timestamp.hour == 0 ? 12 : timestamp.hour);
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

 
  static String formatDetailedTimestamp(DateTime timestamp) {
    return '${timestamp.month}/${timestamp.day}/${timestamp.year} ${formatTimeOnly(timestamp)}';
  }

 
  static String formatChatBubbleDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return 'Today, ${formatTimeOnly(timestamp)}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${formatTimeOnly(timestamp)}';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year} ${formatTimeOnly(timestamp)}';
    }
  }
}