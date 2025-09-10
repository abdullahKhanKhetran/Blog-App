import 'package:blog_app/core/color_pallate.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static _border([Color color = AppPallete.borderColor]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: BorderSide(color: color, width: 1),
  );

  static final DarkTheme = ThemeData.dark(useMaterial3: true);
  static final darkThemeMode = DarkTheme.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      border: _border(),
      disabledBorder: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(Color.fromRGBO(243, 5, 223, 1)),
      errorBorder: _border(AppPallete.errorColor),
      hintStyle: TextStyle(fontSize: 16, color: AppPallete.borderColor),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
    ),
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 36,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(fontSize: 26, color: Colors.white),
      bodySmall: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: TextStyle(fontSize: 16, color: AppPallete.borderColor),
    ),
  );
}
