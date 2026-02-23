import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: Colors.green,
      colorScheme: const ColorScheme.light().copyWith(
        primary: const Color.fromARGB(255, 43, 128, 46),
      ),
      scaffoldBackgroundColor: MyColors.backgroundColor,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        foregroundColor: Colors.black,
        backgroundColor: MyColors.backgroundColor,
        elevation: 0.5,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelLarge,
          iconColor: Colors.white,
          foregroundColor: Colors.white,
          elevation: 1,
        ),
      ),
      // Primary Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),

      // Secondary Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: Color(0x33000000), width: 1),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: MyColors.lightGrey,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: MyColors.contrastColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.black,
        indicatorColor: Colors.black,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MyColors.textColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        headerBackgroundColor: Colors.white,
        headerForegroundColor: MyColors.textColor,
        dayStyle: const TextStyle(color: MyColors.textColor, fontSize: 16, fontWeight: FontWeight.w300),
        yearStyle: const TextStyle(color: MyColors.textColor, fontSize: 16, fontWeight: FontWeight.w500),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: MyColors.textColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: MyColors.textColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: MyColors.textColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: MyColors.textColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        dialBackgroundColor: Colors.white,
        dialTextStyle: const TextStyle(color: MyColors.textColor, fontSize: 16, fontWeight: FontWeight.w300),
        padding: const EdgeInsets.all(20),
      ),
      iconTheme: const IconThemeData(color: MyColors.accentColor),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      ),
      cardColor: const Color(0XFFFFFFFF),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.15), width: 0.65),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: MyColors.backgroundColor,
        selectedItemColor: MyColors.accentColor,
        unselectedItemColor: Colors.black45,
        type: BottomNavigationBarType.fixed,
      ),
      fontFamily: 'Inter',
      textTheme: textTheme,
      listTileTheme: const ListTileThemeData(
        titleTextStyle: TextStyle(color: MyColors.textColor, fontSize: 16, fontWeight: FontWeight.w400, height: 1.2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return MyColors.accentColor; // On color
          }
          return Colors.grey; // Off color
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return MyColors.accentColor.withValues(alpha: 0.5); // On color
          }
          return Colors.grey.withValues(alpha: 0.5); // Off color
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return MyColors.accentColor.withValues(alpha: 0.2); // On color
          }
          return Colors.grey.withValues(alpha: 0.2); // Off color
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return MyColors.accentColor; // On color
          }
          return Colors.white; // Off color
        }),
      ),
    );
  }
}

final textTheme = TextTheme(
  headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, height: 1.15),
  headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.20),
  headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.20),
  displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.w600, height: 1.05),
  titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.25),
  titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4), // Names in list tiles
  titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.25), // Subtitle
  bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.45),
  bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.35), // Main paragraphs of text
  bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.30),
  labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.20),
  labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.15),
  labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.3),
);

class MyColors {
  static const Color textColor = Color.fromRGBO(20, 35, 1, 1);
  static const Color accentColor = Color.fromRGBO(55, 84, 41, 1);
  // static const Color accentColor = Color.fromRGBO(94, 131, 75, 1);
  // static const Color backgroundColor = Color.fromARGB(255, 250, 250, 250);
  static const LinearGradient linearGradient = LinearGradient(
    colors: [Color.fromRGBO(233, 233, 232, 1), Color.fromRGBO(250, 255, 249, 1)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  static const contrastColor = Color.fromRGBO(231, 141, 8, 1);

  static const Color backgroundColor = Color(0xFFF9F9FB); //Color(0xFFFAFAFA); // or FFFFFFFF
  static const Color lightGrey = Color.fromRGBO(230, 234, 233, 1);
  static const Color mutedText = Color.fromRGBO(107, 113, 106, 1);
  static const Color starColor = Color.fromRGBO(253, 199, 0, 1);
  static const Color notificationDotColor = Color(0xFF030213);
  static const Color subtitleColor = Color.fromARGB(255, 63, 63, 63);
}
