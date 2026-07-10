import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wujidt/core/utils/app_colors.dart';
import 'package:wujidt/features/auth/views/login.dart';
import 'package:wujidt/features/auth/views/onboarding.dart';
import 'package:wujidt/features/auth/views/signup.dart';
import 'package:wujidt/features/auth/views/splash.dart';
import 'package:wujidt/features/home/widgets/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: AppColors.primary,
            selectionColor: AppColors.unActive,
            selectionHandleColor: AppColors.primary,
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColors.primary,
          ),
        ),
        routes: {
          '/': (context) => const OnboardingView(),
          'splash': (context) => const Splash(),
          'login': (context) => const Login(),
          'signup': (context) => const Signup(),
          'home': (context) => const MainLayout(),
        },
      ),
    );
  }
}