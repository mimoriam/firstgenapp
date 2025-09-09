import 'package:intl/intl.dart';

class TimeAgo {
  static String format(String isoString) {
    try {
      final now = DateTime.now();
      final messageTime = DateTime.parse(isoString);
      final difference = now.difference(messageTime);

      if (difference.inSeconds < 60) {
        return '${difference.inSeconds}s ago';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${(difference.inDays / 7).floor()}w ago';
      }
    } catch (e) {
      return 'just now';
    }
  }

  static String formatTimestamp(String isoString) {
    try {
      // final messageTime = DateTime.parse(isoString);
      final messageTime = DateTime.parse(isoString).toLocal();
      return DateFormat('HH:mm').format(messageTime);
    } catch (e) {
      return '';
    }
  }

  static String formatDateSeparator(String isoString) {
    try {
      final now = DateTime.now();
      final messageTime = DateTime.parse(isoString);
      final startOfNow = DateTime(now.year, now.month, now.day);
      final startOfMessageTime = DateTime(
        messageTime.year,
        messageTime.month,
        messageTime.day,
      );

      final difference = startOfNow.difference(startOfMessageTime).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else {
        return DateFormat('EEE, dd/MM').format(messageTime);
      }
    } catch (e) {
      return 'A while ago';
    }
  }
}
