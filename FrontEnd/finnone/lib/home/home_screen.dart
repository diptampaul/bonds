import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;

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
  bool isBackendConnected = true;
  bool isLogin = false;

  Future getLoginStatus() async{
    setState(() {
      showSpinner = true;
    });
    var request = http.Request('GET', Uri.parse(backend.HOME));
    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 202) {
        Map<String,dynamic> data = jsonDecode(await response.stream.bytesToString());
        //Check Login Status
        print(data);
        if(data["isLogined"] == false){
          Navigator.pushReplacementNamed(context, '/sign-in');
        }else{
          isLogin = true;
        }
      }else {
        setState(() {
          isBackendConnected = false;
        });
      }
    }on Exception catch (exception) {
      setState(() {
        isBackendConnected = false;
      });
    } catch (error) {
      setState(() {
        isBackendConnected = false;
      });
    }
    setState(() {
      showSpinner = false;
    });
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
      child: isBackendConnected == false ? const ErrorScreen() : Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: CustomAppBar(title: const Text('FinnOne'), appBar: AppBar(),),
        body: isLogin == false ? const ErrorScreen() : Container(
          child: Container(
            child: Text("User Logged In"),
          ),
        ),
      ),
    );
  }
}

