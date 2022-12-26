import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finnone/assets/backend-api.dart' as backend;
import 'package:finnone/main/appbarwithicons.dart';
import 'package:finnone/main/internal_server_error.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showSpinner = false;
  bool isLogin = true;


  Future getLoginStatus() async{
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('loginToken');
    print(token);
    if(token==null){
      isLogin = false;
      Navigator.pushReplacementNamed(context, '/sign-in');
    }else{
      isLogin = true;
    }
  }


  @override
  void initState()
  {
    super.initState();
    getLoginStatus();//call it over here
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: CustomAppBar(title: const Text('FinnOne'), appBar: AppBar(),),
        body: isLogin == false ? Container() : Container(
          child: Container(
            child: Text("User Logged In"),
          ),
        ),
      ),
    );
  }
}

