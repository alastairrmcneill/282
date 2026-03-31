import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: Colors.green,
      colorScheme: const ColorScheme.light().copyWith(
        primary: const Color.fromARGB(255, 43, 128, 46),
      ),
      scaffoldBackgroundColor: AppColors.light.background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        foregroundColor: Colors.black,
        backgroundColor: AppColors.light.background,
        elevation: 0.5,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.light.accent,
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
          backgroundColor: AppColors.light.accent,
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

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.light.accent; // Selected color
            }
            return Colors.transparent; // Unselected color
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white; // Selected text color
            }
            return Colors.black; // Unselected text color
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(
                color: Colors.grey[300]!,
                width: 0.5,
              ); // Selected border
            }
            return BorderSide(
              color: Colors.grey[300]!,
              width: 0.5,
            ); // Unselected border
          }),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Colors.grey[300]!,
                width: 0.5,
              ),
            ),
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(textTheme.labelLarge!),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.light.divider,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.light.accent,
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
          foregroundColor: AppColors.light.textPrimary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        headerBackgroundColor: Colors.white,
        headerForegroundColor: AppColors.light.textPrimary,
        dayStyle: TextStyle(color: AppColors.light.textPrimary, fontSize: 16, fontWeight: FontWeight.w300),
        yearStyle: TextStyle(color: AppColors.light.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.light.textPrimary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.light.textPrimary,
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
          foregroundColor: AppColors.light.textPrimary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.light.textPrimary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        dialBackgroundColor: Colors.white,
        dialTextStyle: TextStyle(color: AppColors.light.textPrimary, fontSize: 16, fontWeight: FontWeight.w300),
        padding: const EdgeInsets.all(20),
      ),
      iconTheme: IconThemeData(color: AppColors.light.accent),
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
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.light.background,
        selectedItemColor: AppColors.light.accent,
        unselectedItemColor: Colors.black45,
        type: BottomNavigationBarType.fixed,
      ),
      fontFamily: 'Inter',
      textTheme: textTheme,
      listTileTheme: ListTileThemeData(
        titleTextStyle:
            TextStyle(color: AppColors.light.textPrimary, fontSize: 16, fontWeight: FontWeight.w400, height: 1.2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.light.accent; // On color
          }
          return Colors.grey; // Off color
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.light.accent.withValues(alpha: 0.5); // On color
          }
          return Colors.grey.withValues(alpha: 0.5); // Off color
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.light.accent.withValues(alpha: 0.2); // On color
          }
          return Colors.grey.withValues(alpha: 0.2); // Off color
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.light.accent; // On color
          }
          return Colors.white; // Off color
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: Colors.green,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: AppColors.dark.accent,
      ),
      scaffoldBackgroundColor: AppColors.dark.background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        foregroundColor: Colors.white,
        backgroundColor: AppColors.dark.background,
        elevation: 0.5,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark.accent,
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
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
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
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: Color(0x33FFFFFF), width: 1),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.dark.accent; // Selected color
            }
            return Colors.transparent; // Unselected color
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white; // Selected text color
            }
            return Colors.white70; // Unselected text color
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((Set<WidgetState> states) {
            return const BorderSide(color: Color(0x33FFFFFF), width: 0.5);
          }),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0x33FFFFFF), width: 0.5),
            ),
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(textTheme.labelLarge!),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.dark.divider,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.dark.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        indicatorColor: Colors.white,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.dark.textPrimary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        headerBackgroundColor: AppColors.dark.surface,
        headerForegroundColor: AppColors.dark.textPrimary,
        dayStyle: TextStyle(color: AppColors.dark.textPrimary, fontSize: 16, fontWeight: FontWeight.w300),
        yearStyle: TextStyle(color: AppColors.dark.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.dark.textPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.dark.textPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.dark.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.dark.textPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.dark.textPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
        dialBackgroundColor: AppColors.dark.surface,
        dialTextStyle: TextStyle(color: AppColors.dark.textPrimary, fontSize: 16, fontWeight: FontWeight.w300),
        padding: const EdgeInsets.all(20),
      ),
      iconTheme: IconThemeData(color: AppColors.dark.accent),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        fillColor: AppColors.dark.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      ),
      cardColor: AppColors.dark.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.dark.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: Color.fromRGBO(255, 255, 255, 0.1), width: 0.65),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.dark.background,
        selectedItemColor: AppColors.dark.accent,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
      ),
      fontFamily: 'Inter',
      textTheme: textTheme.apply(
        bodyColor: AppColors.dark.textPrimary,
        displayColor: AppColors.dark.textPrimary,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle:
            TextStyle(color: AppColors.dark.textPrimary, fontSize: 16, fontWeight: FontWeight.w400, height: 1.2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.dark.accent;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.dark.accent.withValues(alpha: 0.5);
          }
          return Colors.grey.withValues(alpha: 0.5);
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.dark.accent.withValues(alpha: 0.2);
          }
          return Colors.grey.withValues(alpha: 0.2);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.dark.accent;
          }
          return AppColors.dark.surface;
        }),
      ),
    );
  }
}

final textTheme = TextTheme(
  headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, height: 1.25), // Hero heading
  headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.33), // Page title
  headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.25), // Section header
  displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.w600, height: 1.05),
  titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.56), // Subheader
  titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.50), // Subsection header / card title
  titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.43), // Secondary text / subtitle
  bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.50), // Body text default (Base)
  bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.43), // Body text / secondary (SM)
  bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33), // Timestamps / small labels (XS)
  labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.20), // Buttons / interactive
  labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.15),
  labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33),
);

abstract class AppColors {
  const AppColors();

  static const AppColors light = MyLightColors();
  static const AppColors dark = MyDarkColors();

  Color get background;
  Color get surface;
  Color get accent;
  Color get textPrimary;
  Color get textSubtitle;
  Color get textMuted;
  Color get middleGrey;
  Color get border;
  Color get divider;
  Color get starColor;
  // LinearGradient get overlayGradient;
}

class MyLightColors implements AppColors {
  const MyLightColors();

  @override
  Color get background => const Color(0xFFF9FAFB); // gray-50
  @override
  Color get surface => const Color(0xFFFFFFFF); // white
  @override
  Color get accent => const Color(0xFF10B981); // emerald-500
  @override
  Color get textPrimary => const Color(0xFF111827); // gray-900
  @override
  Color get textSubtitle => const Color(0xFF4B5563); // gray-600
  @override
  Color get textMuted => const Color(0xFF6B7280); // gray-500
  @override
  Color get middleGrey => const Color(0xFF9CA3AF); // gray-400
  @override
  Color get border => const Color(0xFFE5E7EB); // gray-200
  @override
  Color get divider => const Color(0xFFE5E7EB); // gray-200
  @override
  Color get starColor => const Color(0xFFF59E0B); // amber-400
  // @override
  // LinearGradient get overlayGradient => const LinearGradient(
  //       begin: Alignment.topCenter,
  //       end: Alignment.bottomCenter,
  //       colors: [Colors.transparent, Color(0x99000000)],
  //     );
}

class MyDarkColors implements AppColors {
  const MyDarkColors();

  @override
  Color get background => const Color(0xFF111827); // gray-900
  @override
  Color get surface => const Color(0xFF1F2937); // gray-800
  @override
  Color get accent => const Color(0xFF11A071); // emerald-500
  @override
  Color get textPrimary => const Color(0xFFFFFFFF); // white
  @override
  Color get textSubtitle => const Color(0xFF9CA3AF); // gray-400
  @override
  Color get textMuted => const Color(0xFF6B7280); // gray-500
  @override
  Color get middleGrey => const Color(0xFF9CA3AF); // gray-400
  @override
  Color get border => const Color(0x1AFFFFFF); // white at 10% opacity
  @override
  Color get divider => const Color(0xFF1F2937); // gray-800
  @override
  Color get starColor => const Color(0xFFF59E0B); // amber-400
  // @override
  // LinearGradient get overlayGradient => const LinearGradient(
  //       begin: Alignment.topCenter,
  //       end: Alignment.bottomCenter,
  //       colors: [Colors.transparent, Color(0xCC000000)],
  //     );
}
