import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_eight_two/extensions/timeofday_extension.dart';

void main() {
  group('TimeOfDay Extension', () {
    test('returns correctly formatted string', () {
      TimeOfDay time = TimeOfDay(hour: 9, minute: 5);
      String result = time.format24Hour();
      expect(result, "09:05");
    });

    test('returns correctly formatted string for midnight', () {
      TimeOfDay time = TimeOfDay(hour: 0, minute: 0);
      String result = time.format24Hour();
      expect(result, "00:00");
    });

    test('returns correct TimeOfDay object from correctly formatted input string', () {
      String input = "14:30";
      TimeOfDay result = TimeOfDayExtension.from24Hour(input);
      expect(result.hour, 14);
      expect(result.minute, 30);
    });
  });
}
