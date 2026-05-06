import 'package:flutter/material.dart';

import 'features/app_shell.dart';
import 'firebase/firebase_bootstrap.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseStatus = await FirebaseBootstrap.initialize();
  runApp(MartApp(firebaseStatus: firebaseStatus));
}

class MartApp extends StatelessWidget {
  const MartApp({super.key, required this.firebaseStatus});

  final FirebaseBootstrapStatus firebaseStatus;

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primaryGreen,
          onPrimary: AppColors.surface,
          primaryContainer: AppColors.softGreen,
          onPrimaryContainer: AppColors.primaryGreen,
          secondary: AppColors.accentOrange,
          onSecondary: AppColors.surface,
          secondaryContainer: AppColors.softOrange,
          onSecondaryContainer: AppColors.accentOrange,
          surface: AppColors.surface,
          error: AppColors.danger,
        );

    return MaterialApp(
      title: '동네마트 특가',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Noto Sans KR',
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primaryGreen,
          surfaceTintColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: IconThemeData(color: AppColors.primaryGreen),
          actionsIconTheme: IconThemeData(color: AppColors.primaryGreen),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.surface,
          surfaceTintColor: AppColors.surface,
          margin: EdgeInsets.zero,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: AppColors.surface,
          indicatorColor: const Color(0xFFDDF7E8),
          height: 70,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primaryGreen
                  : const Color(0xFF7B8794),
              fontSize: 11.8,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w900
                  : FontWeight.w800,
              height: 1.08,
              letterSpacing: 0,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primaryGreen
                  : const Color(0xFF7B8794),
              size: states.contains(WidgetState.selected) ? 24 : 23,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.surface,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.accentOrange,
          foregroundColor: AppColors.surface,
        ),
        chipTheme: ChipThemeData(
          selectedColor: AppColors.softGreen,
          checkmarkColor: AppColors.primaryGreen,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        useMaterial3: true,
      ),
      home: AppShell(firebaseStatus: firebaseStatus),
    );
  }
}
