import 'package:finnone/dashboard/signup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finnone/home/home_screen.dart';
import 'package:finnone/dashboard/signin.dart';
import 'package:finnone/dashboard/signup.dart';
import 'package:finnone/dashboard/reset-password.dart';
import 'package:finnone/main/global.dart';

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
        '/sign-in' : (context) => const SignInScreen(),
        '/sign-up' : (context) => const SignUpScreen(),
        '/reset-password' : (context) => const ResetPasswordScreen(),
      },
    );
    // return FutureBuilder(
    //     future: SharedPreferences.getInstance(),
    //     builder:
    //         (BuildContext context, AsyncSnapshot<SharedPreferences> prefs) {
    //       var x = prefs.data;
    //       if (prefs.hasData) {
    //         final bool? hasLogin = x?.getBool('isLogin');
    //         if (hasLogin == null) {
    //           return const MaterialApp(home: HomeScreen());
    //         }
    //       }
    //       return const MaterialApp(home: SignInScreen());
    //     });

  }

}


