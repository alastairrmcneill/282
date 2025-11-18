import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      primaryColor: Colors.green,
      colorScheme: const ColorScheme.light().copyWith(
        primary: const Color.fromARGB(255, 43, 128, 46),
      ),
      scaffoldBackgroundColor: MyColors.backgroundColor,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        foregroundColor: Colors.black,
        backgroundColor: MyColors.backgroundColor,
        elevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          elevation: 1,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MyColors.accentColor,
          backgroundColor: MyColors.backgroundColor,
          side: const BorderSide(color: MyColors.accentColor, width: 2), // Border color and width
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.all(0),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: MyColors.contrastColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: MyColors.accentColor,
        indicatorColor: MyColors.accentColor,
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
      cardColor: const Color.fromARGB(255, 250, 255, 248),
      cardTheme: const CardThemeData(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: MyColors.backgroundColor,
        selectedItemColor: MyColors.accentColor,
        unselectedItemColor: Colors.black45,
        type: BottomNavigationBarType.fixed,
      ),
      fontFamily: "NotoSans",
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: MyColors.textColor, fontSize: 24, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: MyColors.textColor, fontSize: 13, fontWeight: FontWeight.w300),
        titleLarge: TextStyle(color: MyColors.textColor, fontSize: 20, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: MyColors.textColor, fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
        bodyLarge: TextStyle(color: MyColors.textColor, fontSize: 15, fontWeight: FontWeight.w500, height: 1.8),
        bodyMedium: TextStyle(color: MyColors.textColor, fontSize: 15, fontWeight: FontWeight.w300, height: 1.8),
        bodySmall: TextStyle(color: MyColors.textColor, fontSize: 12, fontWeight: FontWeight.w300, height: 1.1),
      ),
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

class MyColors {
  static const Color textColor = Color.fromRGBO(20, 35, 1, 1);
  static const Color accentColor = Color.fromRGBO(55, 84, 41, 1);
  // static const Color accentColor = Color.fromRGBO(94, 131, 75, 1);
  static const Color backgroundColor = Color.fromARGB(255, 252, 255, 250); //Color.fromARGB(255, 245, 250, 242);
  static const LinearGradient linearGradient = LinearGradient(
    colors: [Color.fromRGBO(233, 233, 232, 1), Color.fromRGBO(250, 255, 249, 1)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  static const contrastColor = Color.fromRGBO(231, 141, 8, 1);
}
