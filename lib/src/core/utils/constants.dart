// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class AppConstants {
  // Spacing constants
  static const double listTileSpacing = 4;
  static const double separatorSpacing = 16;
  static const double paddingSpacing = 16;
  static const double borderRadius = 10;

  // Appwrite constants
  static const String APPWRITE_PROJECT_ID = '6578c59fdf2ca76934dd';
  static const String APPWRITE_API_ENDPOINT =
      'https://appwrite.walter-wm.de/v1';
  static const String APPWRITE_DATABASE_ID = '6660884169dce3a05e38';
  static const String APPWRITE_COMMUNITIES_COLLECTION_ID =
      '666088a92a47959a2ff4';
  static const String APPWRITE_USER_PROFILES_COLLECTION_ID =
      '66915c220021827fbd90';
  static const String APPWRITE_CREATE_COMMUNITY_FUNCTION_ID =
      '6686fcee001e66841fe0';
  static const String APPWRITE_LEAVE_COMMUNITY_FUNCTION_ID =
      '669675be00307be3dd7d';
  static const String APPWRITE_CREATE_ACTIVITY_FUNCTION_ID =
      '6697fb0d001a539980fc';
  static const String APPWRITE_LEAVE_ACTIVITY_FUNCTION_ID =
      '669a1c270019640a6777';
  static const String APPWRITE_RESET_INVITATION_TOKEN_FUNCTION_ID =
      '66a14316002b45aa6d3d';
  static const String APPWRITE_FETCH_COMMUNITY_INVITATION_TOKEN_FUNCTION_ID =
      '66aa861b00385713ab4b';

  // Supabase constants
  static const String SUPABASE_URL = 'https://lbireiylyvvvihabizio.supabase.co';
  static const String SUPABASE_ANON_KEY =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxiaXJlaXlseXZ2dmloYWJpemlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE4MTU3NjIsImV4cCI6MjAzNzM5MTc2Mn0.2Ab2ezHffRpYgd-pikW6CkKy-EW2jnnhuY3K579j7pc';

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
