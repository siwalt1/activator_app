// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class AppConstants {
  // Spacing constants
  static const double listTileSpacing = 4;
  static const double separatorSpacing = 16;
  static const double paddingSpacing = 16;
  static const double borderRadius = 10;

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
      surface: Color.fromARGB(255, 33, 33, 33),
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
  joinCommunity,
  leaveCommunity,
  createCommunity,
  updateCommunity,
}

// notification types constants
enum NotificationType {
  off,
  activityCreationNoJoin,
  all,
}

const Map<NotificationType, String> notificationTypeDescriptions = {
  NotificationType.off: 'Off',
  NotificationType.activityCreationNoJoin: 'When Activity Started',
  NotificationType.all: 'On',
};
