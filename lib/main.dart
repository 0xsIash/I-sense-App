import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isense/features/auth/views/login.dart';
import 'package:isense/features/auth/views/signup.dart';
import 'package:isense/features/auth/views/splash.dart';
import 'package:isense/features/home/views/home_page.dart';

// main function
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
      routes: {
        '/' : (context) => const Splash(),
        'login' : (context) => const Login(),
        'signup' : (context) => const Signup(),
        'home' : (context) => const HomePage(),
      },
      ),
    );
  }
}
