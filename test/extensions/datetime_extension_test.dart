import 'package:flutter_test/flutter_test.dart';
import 'package:two_eight_two/extensions/datetime_extension.dart';

void main() {
  group('DateTimeExtension', () {
    group('timeAgoShort', () {
      test('returns "Now" for time less than 1 minute ago', () {
        final now = DateTime.now().toUtc();
        final thirtySecondsAgo = now.subtract(const Duration(seconds: 30));
        expect(thirtySecondsAgo.timeAgoShort(), 'Now');
      });

      test('returns "1m ago" for 1 minute ago', () {
        final now = DateTime.now().toUtc();
        final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
        expect(oneMinuteAgo.timeAgoShort(), '1m ago');
      });

      test('returns correct minutes for time less than 1 hour ago', () {
        final now = DateTime.now().toUtc();
        final thirtyMinutesAgo = now.subtract(const Duration(minutes: 30));
        expect(thirtyMinutesAgo.timeAgoShort(), '30m ago');
      });

      test('returns "59m ago" for 59 minutes ago', () {
        final now = DateTime.now().toUtc();
        final fiftyNineMinutesAgo = now.subtract(const Duration(minutes: 59));
        expect(fiftyNineMinutesAgo.timeAgoShort(), '59m ago');
      });

      test('returns "1h ago" for 1 hour ago', () {
        final now = DateTime.now().toUtc();
        final oneHourAgo = now.subtract(const Duration(hours: 1));
        expect(oneHourAgo.timeAgoShort(), '1h ago');
      });

      test('returns correct hours for time less than 1 day ago', () {
        final now = DateTime.now().toUtc();
        final twelveHoursAgo = now.subtract(const Duration(hours: 12));
        expect(twelveHoursAgo.timeAgoShort(), '12h ago');
      });

      test('returns "23h ago" for 23 hours ago', () {
        final now = DateTime.now().toUtc();
        final twentyThreeHoursAgo = now.subtract(const Duration(hours: 23));
        expect(twentyThreeHoursAgo.timeAgoShort(), '23h ago');
      });

      test('returns "1d ago" for 1 day ago', () {
        final now = DateTime.now().toUtc();
        final oneDayAgo = now.subtract(const Duration(days: 1));
        expect(oneDayAgo.timeAgoShort(), '1d ago');
      });

      test('returns correct days for time less than or equal to 1 week ago', () {
        final now = DateTime.now().toUtc();
        final fiveDaysAgo = now.subtract(const Duration(days: 5));
        expect(fiveDaysAgo.timeAgoShort(), '5d ago');
      });

      test('returns "7d ago" for exactly 1 week ago', () {
        final now = DateTime.now().toUtc();
        final oneWeekAgo = now.subtract(const Duration(days: 7));
        expect(oneWeekAgo.timeAgoShort(), '7d ago');
      });

      test('returns "1w ago" for 8 days ago', () {
        final now = DateTime.now().toUtc();
        final eightDaysAgo = now.subtract(const Duration(days: 8));
        expect(eightDaysAgo.timeAgoShort(), '1w ago');
      });

      test('returns correct weeks for time less than 1 year ago', () {
        final now = DateTime.now().toUtc();
        final fourWeeksAgo = now.subtract(const Duration(days: 28));
        expect(fourWeeksAgo.timeAgoShort(), '4w ago');
      });

      test('returns "52w ago" for approximately 1 year ago', () {
        final now = DateTime.now().toUtc();
        final oneYearAgo = now.subtract(const Duration(days: 364));
        expect(oneYearAgo.timeAgoShort(), '52w ago');
      });

      test('returns "1y ago" for exactly 365 days ago', () {
        final now = DateTime.now().toUtc();
        final oneYearAgo = now.subtract(const Duration(days: 365));
        expect(oneYearAgo.timeAgoShort(), '1y ago');
      });

      test('returns "1y ago" for more than 1 year but less than 2 years ago', () {
        final now = DateTime.now().toUtc();
        final oneAndHalfYearsAgo = now.subtract(const Duration(days: 547));
        expect(oneAndHalfYearsAgo.timeAgoShort(), '1y ago');
      });

      test('returns correct years for time more than 1 year ago', () {
        final now = DateTime.now().toUtc();
        final twoYearsAgo = now.subtract(const Duration(days: 730));
        expect(twoYearsAgo.timeAgoShort(), '2y ago');
      });

      test('returns correct years for multiple years ago', () {
        final now = DateTime.now().toUtc();
        final fiveYearsAgo = now.subtract(const Duration(days: 1825));
        expect(fiveYearsAgo.timeAgoShort(), '5y ago');
      });
    });

    group('timeAgoLong', () {
      test('returns "Now" for time less than 1 minute ago', () {
        final now = DateTime.now().toUtc();
        final thirtySecondsAgo = now.subtract(const Duration(seconds: 30));
        expect(thirtySecondsAgo.timeAgoLong(), 'Now');
      });

      test('returns "Now" for exactly 0 seconds ago', () {
        final now = DateTime.now().toUtc();
        expect(now.timeAgoLong(), 'Now');
      });

      test('returns "1 minute ago" for exactly 1 minute ago', () {
        final now = DateTime.now().toUtc();
        final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
        expect(oneMinuteAgo.timeAgoLong(), '1 minute ago');
      });

      test('returns "2 minutes ago" for 2 minutes ago', () {
        final now = DateTime.now().toUtc();
        final twoMinutesAgo = now.subtract(const Duration(minutes: 2));
        expect(twoMinutesAgo.timeAgoLong(), '2 minutes ago');
      });

      test('returns correct plural minutes for time less than 1 hour ago', () {
        final now = DateTime.now().toUtc();
        final thirtyMinutesAgo = now.subtract(const Duration(minutes: 30));
        expect(thirtyMinutesAgo.timeAgoLong(), '30 minutes ago');
      });

      test('returns "59 minutes ago" for 59 minutes ago', () {
        final now = DateTime.now().toUtc();
        final fiftyNineMinutesAgo = now.subtract(const Duration(minutes: 59));
        expect(fiftyNineMinutesAgo.timeAgoLong(), '59 minutes ago');
      });

      test('returns "1 hour ago" for exactly 1 hour ago', () {
        final now = DateTime.now().toUtc();
        final oneHourAgo = now.subtract(const Duration(hours: 1));
        expect(oneHourAgo.timeAgoLong(), '1 hour ago');
      });

      test('returns "2 hours ago" for 2 hours ago', () {
        final now = DateTime.now().toUtc();
        final twoHoursAgo = now.subtract(const Duration(hours: 2));
        expect(twoHoursAgo.timeAgoLong(), '2 hours ago');
      });

      test('returns correct plural hours for time less than 1 day ago', () {
        final now = DateTime.now().toUtc();
        final twelveHoursAgo = now.subtract(const Duration(hours: 12));
        expect(twelveHoursAgo.timeAgoLong(), '12 hours ago');
      });

      test('returns "23 hours ago" for 23 hours ago', () {
        final now = DateTime.now().toUtc();
        final twentyThreeHoursAgo = now.subtract(const Duration(hours: 23));
        expect(twentyThreeHoursAgo.timeAgoLong(), '23 hours ago');
      });

      test('returns "1 day ago" for exactly 1 day ago', () {
        final now = DateTime.now().toUtc();
        final oneDayAgo = now.subtract(const Duration(days: 1));
        expect(oneDayAgo.timeAgoLong(), '1 day ago');
      });

      test('returns "2 days ago" for 2 days ago', () {
        final now = DateTime.now().toUtc();
        final twoDaysAgo = now.subtract(const Duration(days: 2));
        expect(twoDaysAgo.timeAgoLong(), '2 days ago');
      });

      test('returns correct plural days for time less than or equal to 1 week ago', () {
        final now = DateTime.now().toUtc();
        final fiveDaysAgo = now.subtract(const Duration(days: 5));
        expect(fiveDaysAgo.timeAgoLong(), '5 days ago');
      });

      test('returns "7 days ago" for exactly 1 week ago', () {
        final now = DateTime.now().toUtc();
        final oneWeekAgo = now.subtract(const Duration(days: 7));
        expect(oneWeekAgo.timeAgoLong(), '7 days ago');
      });

      test('returns "1 week ago" for 8-13 days ago', () {
        final now = DateTime.now().toUtc();
        final eightDaysAgo = now.subtract(const Duration(days: 8));
        expect(eightDaysAgo.timeAgoLong(), '1 week ago');

        final thirteenDaysAgo = now.subtract(const Duration(days: 13));
        expect(thirteenDaysAgo.timeAgoLong(), '1 week ago');
      });

      test('returns "2 weeks ago" for 14-20 days ago', () {
        final now = DateTime.now().toUtc();
        final fourteenDaysAgo = now.subtract(const Duration(days: 14));
        expect(fourteenDaysAgo.timeAgoLong(), '2 weeks ago');

        final twentyDaysAgo = now.subtract(const Duration(days: 20));
        expect(twentyDaysAgo.timeAgoLong(), '2 weeks ago');
      });

      test('returns correct plural weeks for time less than 1 year ago', () {
        final now = DateTime.now().toUtc();
        final fourWeeksAgo = now.subtract(const Duration(days: 28));
        expect(fourWeeksAgo.timeAgoLong(), '4 weeks ago');
      });

      test('returns "52 weeks ago" for approximately 1 year ago', () {
        final now = DateTime.now().toUtc();
        final oneYearAgo = now.subtract(const Duration(days: 364));
        expect(oneYearAgo.timeAgoLong(), '52 weeks ago');
      });

      test('returns "1 year ago" for 365-729 days ago', () {
        final now = DateTime.now().toUtc();
        final oneYearAgo = now.subtract(const Duration(days: 365));
        expect(oneYearAgo.timeAgoLong(), '1 year ago');

        final almostTwoYearsAgo = now.subtract(const Duration(days: 729));
        expect(almostTwoYearsAgo.timeAgoLong(), '1 year ago');
      });

      test('returns "2 years ago" for exactly 730 days ago', () {
        final now = DateTime.now().toUtc();
        final twoYearsAgo = now.subtract(const Duration(days: 730));
        expect(twoYearsAgo.timeAgoLong(), '2 years ago');
      });

      test('returns correct plural years for multiple years ago', () {
        final now = DateTime.now().toUtc();
        final fiveYearsAgo = now.subtract(const Duration(days: 1825));
        expect(fiveYearsAgo.timeAgoLong(), '5 years ago');
      });
    });

    group('dayOfWeek', () {
      test('returns "Monday" for weekday 1', () {
        final monday = DateTime(2024, 12, 16); // This is a Monday
        expect(monday.dayOfWeek(), 'Monday');
      });

      test('returns "Tuesday" for weekday 2', () {
        final tuesday = DateTime(2024, 12, 17); // This is a Tuesday
        expect(tuesday.dayOfWeek(), 'Tuesday');
      });

      test('returns "Wednesday" for weekday 3', () {
        final wednesday = DateTime(2024, 12, 18); // This is a Wednesday
        expect(wednesday.dayOfWeek(), 'Wednesday');
      });

      test('returns "Thursday" for weekday 4', () {
        final thursday = DateTime(2024, 12, 19); // This is a Thursday
        expect(thursday.dayOfWeek(), 'Thursday');
      });

      test('returns "Friday" for weekday 5', () {
        final friday = DateTime(2024, 12, 20); // This is a Friday
        expect(friday.dayOfWeek(), 'Friday');
      });

      test('returns "Saturday" for weekday 6', () {
        final saturday = DateTime(2024, 12, 21); // This is a Saturday
        expect(saturday.dayOfWeek(), 'Saturday');
      });

      test('returns "Sunday" for weekday 7', () {
        final sunday = DateTime(2024, 12, 22); // This is a Sunday
        expect(sunday.dayOfWeek(), 'Sunday');
      });
    });

    group('dayOfWeekShort', () {
      test('returns "Mon" for weekday 1', () {
        final monday = DateTime(2024, 12, 16);
        expect(monday.dayOfWeekShort(), 'Mon');
      });

      test('returns "Tue" for weekday 2', () {
        final tuesday = DateTime(2024, 12, 17);
        expect(tuesday.dayOfWeekShort(), 'Tue');
      });

      test('returns "Wed" for weekday 3', () {
        final wednesday = DateTime(2024, 12, 18);
        expect(wednesday.dayOfWeekShort(), 'Wed');
      });

      test('returns "Thu" for weekday 4', () {
        final thursday = DateTime(2024, 12, 19);
        expect(thursday.dayOfWeekShort(), 'Thu');
      });

      test('returns "Fri" for weekday 5', () {
        final friday = DateTime(2024, 12, 20);
        expect(friday.dayOfWeekShort(), 'Fri');
      });

      test('returns "Sat" for weekday 6', () {
        final saturday = DateTime(2024, 12, 21);
        expect(saturday.dayOfWeekShort(), 'Sat');
      });

      test('returns "Sun" for weekday 7', () {
        final sunday = DateTime(2024, 12, 22);
        expect(sunday.dayOfWeekShort(), 'Sun');
      });
    });

    group('dayOfWeekLetter', () {
      test('returns "M" for Monday (weekday 1)', () {
        final monday = DateTime(2024, 12, 16);
        expect(monday.dayOfWeekLetter(), 'M');
      });

      test('returns "T" for Tuesday (weekday 2)', () {
        final tuesday = DateTime(2024, 12, 17);
        expect(tuesday.dayOfWeekLetter(), 'T');
      });

      test('returns "W" for Wednesday (weekday 3)', () {
        final wednesday = DateTime(2024, 12, 18);
        expect(wednesday.dayOfWeekLetter(), 'W');
      });

      test('returns "T" for Thursday (weekday 4)', () {
        final thursday = DateTime(2024, 12, 19);
        expect(thursday.dayOfWeekLetter(), 'T');
      });

      test('returns "F" for Friday (weekday 5)', () {
        final friday = DateTime(2024, 12, 20);
        expect(friday.dayOfWeekLetter(), 'F');
      });

      test('returns "S" for Saturday (weekday 6)', () {
        final saturday = DateTime(2024, 12, 21);
        expect(saturday.dayOfWeekLetter(), 'S');
      });

      test('returns "S" for Sunday (weekday 7)', () {
        final sunday = DateTime(2024, 12, 22);
        expect(sunday.dayOfWeekLetter(), 'S');
      });
    });

    group('longDate', () {
      test('returns correct format for January date', () {
        final date = DateTime(2024, 1, 15); // Monday
        expect(date.longDate(), 'Monday, 15 January 2024');
      });

      test('returns correct format for February date', () {
        final date = DateTime(2024, 2, 20); // Tuesday
        expect(date.longDate(), 'Tuesday, 20 February 2024');
      });

      test('returns correct format for March date', () {
        final date = DateTime(2024, 3, 13); // Wednesday
        expect(date.longDate(), 'Wednesday, 13 March 2024');
      });

      test('returns correct format for April date', () {
        final date = DateTime(2024, 4, 18); // Thursday
        expect(date.longDate(), 'Thursday, 18 April 2024');
      });

      test('returns correct format for May date', () {
        final date = DateTime(2024, 5, 10); // Friday
        expect(date.longDate(), 'Friday, 10 May 2024');
      });

      test('returns correct format for June date', () {
        final date = DateTime(2024, 6, 1); // Saturday
        expect(date.longDate(), 'Saturday, 1 June 2024');
      });

      test('returns correct format for July date', () {
        final date = DateTime(2024, 7, 21); // Sunday
        expect(date.longDate(), 'Sunday, 21 July 2024');
      });

      test('returns correct format for August date', () {
        final date = DateTime(2024, 8, 5); // Monday
        expect(date.longDate(), 'Monday, 5 August 2024');
      });

      test('returns correct format for September date', () {
        final date = DateTime(2024, 9, 10); // Tuesday
        expect(date.longDate(), 'Tuesday, 10 September 2024');
      });

      test('returns correct format for October date', () {
        final date = DateTime(2024, 10, 16); // Wednesday
        expect(date.longDate(), 'Wednesday, 16 October 2024');
      });

      test('returns correct format for November date', () {
        final date = DateTime(2024, 11, 21); // Thursday
        expect(date.longDate(), 'Thursday, 21 November 2024');
      });

      test('returns correct format for December date', () {
        final date = DateTime(2024, 12, 20); // Friday
        expect(date.longDate(), 'Friday, 20 December 2024');
      });

      test('returns correct format for single digit day', () {
        final date = DateTime(2024, 6, 5); // Wednesday
        expect(date.longDate(), 'Wednesday, 5 June 2024');
      });

      test('returns correct format for double digit day', () {
        final date = DateTime(2024, 6, 25); // Tuesday
        expect(date.longDate(), 'Tuesday, 25 June 2024');
      });

      test('returns correct format for different years', () {
        final date1 = DateTime(2020, 3, 15);
        expect(date1.longDate(), 'Sunday, 15 March 2020');

        final date2 = DateTime(2025, 12, 25);
        expect(date2.longDate(), 'Thursday, 25 December 2025');
      });

      test('returns correct format for leap year date', () {
        final date = DateTime(2024, 2, 29); // Thursday (2024 is a leap year)
        expect(date.longDate(), 'Thursday, 29 February 2024');
      });

      test('returns correct format for first day of year', () {
        final date = DateTime(2024, 1, 1); // Monday
        expect(date.longDate(), 'Monday, 1 January 2024');
      });

      test('returns correct format for last day of year', () {
        final date = DateTime(2024, 12, 31); // Tuesday
        expect(date.longDate(), 'Tuesday, 31 December 2024');
      });
    });
  });
}
