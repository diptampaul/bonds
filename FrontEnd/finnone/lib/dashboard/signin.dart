import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finnone/assets/backend-api.dart' as backend;
import 'package:finnone/main/appbarwithtitle.dart';
import 'package:finnone/main/internal_server_error.dart';
import 'package:finnone/main/show_message.dart';
import 'package:finnone/main/global.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);
  // Obtain shared preferences.

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool showSpinner = false;
  bool isBackendConnected = true;

  TextEditingController _emailTextEditor = TextEditingController();
  TextEditingController _passwordTextEditor = TextEditingController();

  Future<void> postSignIn() async{
    setState(() {
      showSpinner = true;
    });
    var email = _emailTextEditor.text;
    if (email.contains("@") & email.contains(".")){
      var password = _passwordTextEditor.text;
      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST', Uri.parse(backend.SIGNIN));
      request.body = json.encode({
        "email": email,
        "password": password
      });
      request.headers.addAll(headers);

      try {
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 202) {
          Map<String,dynamic> data = jsonDecode(await response.stream.bytesToString());
          //Check Login Status
          print(data);
          if(data["isLogined"] == false){
            print("Sign In Failed");
            SnackBar snackBar = showMessage("Oh Snaps !!", "Invalid Email or Password", Colors.redAccent, 2);
            snackbarKey.currentState?.showSnackBar(snackBar);
          }
          else{
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('loginToken', data["token"].toString());
            Navigator.pushReplacementNamed(context, '/');
          }
        }else {
          SnackBar snackBar = showMessage("Sorry !!", "Something bad happened at our side", Colors.redAccent, 2);
          snackbarKey.currentState?.showSnackBar(snackBar);
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
    }else{
      SnackBar snackBar = showMessage("Wait !!", "Your email id seems wrong", Colors.redAccent, 2);
      snackbarKey.currentState?.showSnackBar(snackBar);
    }
    setState(() {
      showSpinner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: isBackendConnected == false ? const ErrorScreen() : Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/dashboard/login.png'), fit: BoxFit.cover),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: CustomAppBarTitle(title: const Text('Welcome Back'), appBar: AppBar(),),
              body: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 35, top: 80),
                    child: const Text(
                      ' Hello !!\n- FinnOne シ',
                      style: TextStyle(color: Colors.white, fontSize: 33),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 35, right: 35),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _emailTextEditor,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                      fillColor: Colors.grey.shade100,
                                      filled: true,
                                      hintText: "Email",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                ),
                                const SizedBox(height: 30,),
                                TextField(
                                  controller: _passwordTextEditor,
                                  style: const TextStyle(color: Colors.black),
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      fillColor: Colors.grey.shade100,
                                      filled: true,
                                      hintText: "Password",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                ),
                                const SizedBox(height: 40,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Sign in',
                                      style: TextStyle(
                                          fontSize: 27, fontWeight: FontWeight.w700),
                                    ),
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.grey[850],
                                      child: IconButton(
                                          color: Colors.white,
                                          onPressed: () {
                                            postSignIn();
                                          },
                                          icon: const Icon(
                                            Icons.arrow_forward,
                                          )),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 40,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/sign-up');
                                      },
                                      style: ButtonStyle(),
                                      child: Text(
                                        'Sign Up',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            decoration: TextDecoration.underline,
                                            color: Colors.grey[850],
                                            fontSize: 18),
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: () {Navigator.pushNamed(context, '/reset-password');},
                                        child: Text(
                                          'Forgot Password',
                                          style: TextStyle(
                                            decoration: TextDecoration.underline,
                                            color: Colors.grey[850],
                                            fontSize: 18,
                                          ),
                                        )),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      );
  }
}



