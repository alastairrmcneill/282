import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  String format24Hour() {
    final String hour = this.hour.toString().padLeft(2, '0');
    final String minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static TimeOfDay from24Hour(String src) {
    return TimeOfDay(
      hour: int.parse(src.split(":")[0]),
      minute: int.parse(src.split(":")[1]),
    );
  }
}
