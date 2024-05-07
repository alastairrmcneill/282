import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: MyColors.accentColor),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      ),
      fontFamily: "Poppins",
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: MyColors.textColor, fontSize: 24, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: MyColors.textColor, fontSize: 13, fontWeight: FontWeight.w300),
        titleLarge: TextStyle(color: MyColors.textColor, fontSize: 20, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: MyColors.textColor, fontSize: 15, fontWeight: FontWeight.w400, height: 1.8),
      ),
    );
  }
}

class MyColors {
  static const Color textColor = Color.fromRGBO(25, 40, 5, 1);
  static const Color accentColor = Color.fromRGBO(94, 131, 75, 1);
  static const Color backgroundColor = Color.fromARGB(255, 245, 250, 242);
  static const LinearGradient linearGradient = LinearGradient(
    colors: [Color.fromRGBO(233, 233, 232, 1), Color.fromRGBO(250, 255, 249, 1)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
}
