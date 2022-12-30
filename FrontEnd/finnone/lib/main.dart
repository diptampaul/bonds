import 'package:flutter/material.dart';

import 'package:finnone/home/home_screen.dart';
import 'package:finnone/dashboard/signin.dart';
import 'package:finnone/dashboard/signup.dart';
import 'package:finnone/dashboard/reset-password.dart';
import 'package:finnone/main/global.dart';
import 'package:finnone/dashboard/signup.dart';
import 'package:finnone/home/main_screen.dart';

void main() async{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinnOne Demo',
      scaffoldMessengerKey: snackbarKey,
      // home: const HomeScreen(),
      initialRoute: '/',
      routes: {
        '/' : (context) => const HomeScreen(),
        '/main' : (context) => const MainScreen(),
        '/sign-in' : (context) => const SignInScreen(),
        '/sign-up' : (context) => const SignUpScreen(),
        '/reset-password' : (context) => const ResetPasswordScreen(),
      },
    );

  }

}


