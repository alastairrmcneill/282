extension DateTimeExtension on DateTime {
  String timeAgoShort() {
    DateTime current = DateTime.now().toUtc();

    if (current.difference(this).inSeconds < 60) {
      // Less than 1 minute ago
      return "Now";
    }
    if (current.difference(this).inMinutes < 60) {
      // Less than 1 hour ago
      return "${current.difference(this).inMinutes}m ago";
    }
    if (current.difference(this).inHours < 24) {
      // Less than 1 day ago
      return "${current.difference(this).inHours}h ago";
    }
    if (current.difference(this).inDays <= 7) {
      // Less than 1 week ago
      return "${current.difference(this).inDays}d ago";
    } else {
      // Any time gets converted to weeks
      return "${current.difference(this).inDays ~/ 7}w ago";
    }
  }

  String timeAgoLong() {
    DateTime current = DateTime.now().toUtc();

    if (current.difference(this).inSeconds < 60) {
      // Less than 1 minute ago
      return "Now";
    }
    if (current.difference(this).inMinutes < 60) {
      // Less than 1 hour ago
      if (current.difference(this).inMinutes == 1) {
        return "${current.difference(this).inMinutes} minute ago";
      }
      return "${current.difference(this).inMinutes} minutes ago";
    }
    if (current.difference(this).inHours < 24) {
      // Less than 1 day ago
      if (current.difference(this).inHours == 1) {
        return "${current.difference(this).inHours} hour ago";
      }
      return "${current.difference(this).inHours} hours ago";
    }
    if (current.difference(this).inDays <= 7) {
      // Less than 1 week ago
      if (current.difference(this).inDays == 1) {
        return "${current.difference(this).inDays} day ago";
      }
      return "${current.difference(this).inDays} days ago";
    } else {
      // Any time gets converted to weeks
      if (current.difference(this).inDays < 14) {
        return "1 week ago";
      }
      return "${current.difference(this).inDays ~/ 7} weeks ago";
    }
  }

  String dayOfWeek() {
    switch (weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "";
    }
  }

  String dayOfWeekShort() {
    switch (weekday) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        return "";
    }
  }
}
