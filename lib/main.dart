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
          indicatorColor: AppColors.softGreen,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primaryGreen
                  : AppColors.textGray,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primaryGreen
                  : AppColors.textGray,
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
