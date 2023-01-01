import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:finnone/assets/backend-api.dart' as backend;
import 'package:finnone/main/show_message.dart';
import 'package:finnone/main/appbarwithicons.dart';
import 'package:finnone/main/global.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool showSpinner = false;

  late int _selected_index = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const Text("Bonds"),
    const Text("Insurance"),
    const Text("Investments"),
    const Text("Profile"),
  ];
  void navButtonTap(int index){
    setState(() {
      _selected_index = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        body: Center(
          child: _widgetOptions[_selected_index],
        ),
        bottomNavigationBar: BottomNavigationBar(items: const [
          BottomNavigationBarItem(icon: Icon(FluentIcons.home_32_regular), activeIcon: Icon(FluentIcons.home_32_filled), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.health_and_safety_outlined), activeIcon: Icon(Icons.health_and_safety_rounded), label: "INSURANCE"),
          BottomNavigationBarItem(icon: Icon(FluentIcons.currency_dollar_rupee_24_regular), activeIcon: Icon(FluentIcons.currency_dollar_rupee_24_filled), label: "INVESTMENTS"),
          BottomNavigationBarItem(icon: Icon(FluentIcons.inprivate_account_28_regular), activeIcon: Icon(FluentIcons.inprivate_account_28_filled), label: "PROFILE"),
        ],
          currentIndex: _selected_index,
          onTap: navButtonTap,
          elevation: 10,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.grey[900],
          unselectedItemColor: Colors.grey[800],),
      ),
    );
  }
}

