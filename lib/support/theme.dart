import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
      cardColor: Color.fromARGB(255, 250, 255, 248),
      cardTheme: const CardTheme(
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
      fontFamily: "Poppins",
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: MyColors.textColor, fontSize: 24, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: MyColors.textColor, fontSize: 13, fontWeight: FontWeight.w300),
        titleLarge: TextStyle(color: MyColors.textColor, fontSize: 20, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: MyColors.textColor, fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
        bodyMedium: TextStyle(color: MyColors.textColor, fontSize: 15, fontWeight: FontWeight.w300, height: 1.8),
        bodySmall: TextStyle(color: MyColors.textColor, fontSize: 12, fontWeight: FontWeight.w300, height: 1.1),
      ),
      listTileTheme: const ListTileThemeData(
        titleTextStyle: TextStyle(color: MyColors.textColor, fontSize: 16, fontWeight: FontWeight.w400, height: 1.2),
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
}
