import 'package:flutter/material.dart';

class AppConstants {
  // Spacing constants
  static const double listTileSpacing = 4;
  static const double separatorSpacing = 16;
  static const double paddingSpacing = 16;
  static const double borderRadius = 10;

  // Appwrite constants
  static const String APPWRITE_PROJECT_ID = '6578c59fdf2ca76934dd';
  static const String APPWRITE_API_ENDPOINT = 'https://appwrite.walter-wm.de/v1';
  static const String APPWRITE_DATABASE_ID = '6660884169dce3a05e38';
  static const String APPWRITE_COMMUNITIES_COLLECTION_ID = '666088a92a47959a2ff4';
  static const String APPWRITE_ACTIVITIES_COLLECTION_ID = '666089e1604ff3e68f0c';
  static const String APPWRITE_COMMUNITY_MEMBERSHIPS_COLLECTION_ID = '6660cf0cb1b829e63b84';
  static const String APPWRITE_ACTIVITY_ATTENDANCE_COLLECTION_ID = '6660cf253e1219a8f2b5';

  // Theme constants
  static Color primaryRed = const Color(0xFFC62828);
  static Color secondaryRed = const Color(0xFFFFCDD2);
  static Color errorRed = const Color(0xFFD32F2F);
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.red,
    colorScheme: ColorScheme(
      primary: primaryRed,
      secondary: secondaryRed,
      surface: Colors.grey.shade100,
      surfaceContainer: Colors.white,
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.grey.shade900,
      onError: Colors.white,
      onSurfaceVariant: Colors.grey.shade600,
      shadow: Colors.grey.withOpacity(0.3),
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade100,
      scrolledUnderElevation: 0,
    ),
  );
  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.red,
    colorScheme: ColorScheme(
      primary: primaryRed,
      secondary: secondaryRed,
      surface: Colors.grey.shade900,
      surfaceContainer: Colors.grey.shade800,
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.black,
      onSurfaceVariant: Colors.grey.shade400,
      shadow: Colors.black.withOpacity(0.3),
      brightness: Brightness.dark,
    ),
    dividerColor: Colors.grey.shade600,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      scrolledUnderElevation: 0,
    ),
  );
}


// Activity types constants
enum ActivityType {
  solo,
  multi,
}