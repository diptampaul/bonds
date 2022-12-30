import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finnone/assets/backend-api.dart' as backend;
import 'package:finnone/main/show_message.dart';
import 'package:finnone/main/global.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showSpinner = false;
  bool isLogin = true;
  late String _token;
  late String _loginPin;
  bool asktoCreateLoginPin = false;
  bool askLoginPin = false;

  final TextEditingController _pin1 = TextEditingController();
  final TextEditingController _pin2 = TextEditingController();
  final TextEditingController _pin3 = TextEditingController();
  final TextEditingController _pin4 = TextEditingController();
  final TextEditingController _pin5 = TextEditingController();
  final TextEditingController _pin6 = TextEditingController();

  final TextEditingController _pinToVerify1 = TextEditingController();
  final TextEditingController _pinToVerify2 = TextEditingController();
  final TextEditingController _pinToVerify3 = TextEditingController();
  final TextEditingController _pinToVerify4 = TextEditingController();
  final TextEditingController _pinToVerify5 = TextEditingController();
  final TextEditingController _pinToVerify6 = TextEditingController();


  Future<void> getLoginPin() async{
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse(backend.HOME));
    request.body = json.encode({
      "login_token": _token
    });
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 202) {
        Map<String,dynamic> data = jsonDecode(await response.stream.bytesToString());
        //Check Login Status
        print(data);
        if(data["errorCode"] == 1){
          SnackBar snackBar = showMessage("Oh Snaps !!", data['message'].toString(), Colors.redAccent, 2);
          snackbarKey.currentState?.showSnackBar(snackBar);
        }else if(data["errorCode"] == 2){
          setState(() {
            askLoginPin =  true;
            asktoCreateLoginPin = true;
          });
        }
        else{
          setState(() {
            _loginPin = data["loginpin"].toString();
            askLoginPin =  true;
            asktoCreateLoginPin = false;
          });
        }
      }else {
        SnackBar snackBar = showMessage("Sorry !!", "Something bad happened at our side", Colors.redAccent, 2);
        snackbarKey.currentState?.showSnackBar(snackBar);
      }
    }on Exception catch (exception) {
      SnackBar snackBar = showMessage("Sorry !!", exception.toString(), Colors.redAccent, 2);
      snackbarKey.currentState?.showSnackBar(snackBar);
    } catch (error) {
      SnackBar snackBar = showMessage("Sorry !!", error.toString(), Colors.redAccent, 2);
      snackbarKey.currentState?.showSnackBar(snackBar);
    }
  }


  Future getLoginStatus() async{
    setState(() {
      showSpinner = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('loginToken');
    print(token);
    if(token==null){
      isLogin = false;
      Navigator.pushReplacementNamed(context, '/sign-in');
    }else{
      _token = token;
      getLoginPin();
      isLogin = true;
    }
    setState(() {
      showSpinner = false;
    });
  }


  Future<void> pinCreation() async{
    setState(() {
      showSpinner = true;
    });
    if(_pin1.text.toString()==_pinToVerify1.text.toString() && _pin2.text.toString()==_pinToVerify2.text.toString() && _pin3.text.toString()==_pinToVerify3.text.toString() && _pin4.text.toString()==_pinToVerify4.text.toString() && _pin5.text.toString()==_pinToVerify5.text.toString() && _pin6.text.toString()==_pinToVerify6.text.toString() ){
      _loginPin = _pin1.text.toString() + _pin2.text.toString() + _pin3.text.toString() + _pin4.text.toString() + _pin5.text.toString() + _pin6.text.toString();
      print(_loginPin);
      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST', Uri.parse(backend.ADD_LOGIN_PIN));
      request.body = json.encode({
        "login_token": _token,
        "login_pin": _loginPin
      });
      request.headers.addAll(headers);

      try {
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 202) {
          Map<String,dynamic> data = jsonDecode(await response.stream.bytesToString());
          //Check Login Status
          print(data);
          if(data["errorCode"] == 1){
            SnackBar snackBar = showMessage("Oh Snaps !!", "Pin doesn't match", Colors.redAccent, 2);
            snackbarKey.currentState?.showSnackBar(snackBar);
          }else{
            SnackBar snackBar = showMessage("Success !!", "Pin Set Successfully", Colors.blueGrey, 2);
            snackbarKey.currentState?.showSnackBar(snackBar);
            setState(() {
              askLoginPin =  false;
              asktoCreateLoginPin = false;
            });
            Navigator.pushReplacementNamed(context, '/main');
          }
        }else {
          SnackBar snackBar = showMessage("Sorry !!", "Something bad happened at our side", Colors.redAccent, 2);
          snackbarKey.currentState?.showSnackBar(snackBar);
        }
      }on Exception catch (exception) {
        SnackBar snackBar = showMessage("Sorry !!", exception.toString(), Colors.redAccent, 2);
        snackbarKey.currentState?.showSnackBar(snackBar);
      } catch (error) {
        SnackBar snackBar = showMessage("Sorry !!", error.toString(), Colors.redAccent, 2);
        snackbarKey.currentState?.showSnackBar(snackBar);
      }
    }else{
      SnackBar snackBar = showMessage("Oh Snaps !!", "Pin doesn't match", Colors.redAccent, 4);
      snackbarKey.currentState?.showSnackBar(snackBar);
    }
    setState(() {
      showSpinner = false;
    });
  }


  Future<void> loginSubmit() async{
    setState(() {
      showSpinner = true;
    });
    if(_loginPin == (_pin1.text.toString() + _pin2.text.toString() + _pin3.text.toString() + _pin4.text.toString() + _pin5.text.toString() + _pin6.text.toString()).toString()){
      print("Pin verification success");
      Navigator.pushReplacementNamed(context, '/main');
    }else{
      SnackBar snackBar = showMessage("Oh Snaps !!", "Pin doesn't match", Colors.redAccent, 4);
      snackbarKey.currentState?.showSnackBar(snackBar);
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
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.grey[850],
          title: const Text("FinnOne"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                //action for user icon button
                final prefs = await SharedPreferences.getInstance();
                // Remove data for the 'counter' key.
                final success = await prefs.remove('loginToken');
                Navigator.pushReplacementNamed(context, '/');
              },
            )
          ],
        ),
        body: isLogin == false ? Container() : Container(
          child: Stack(
            children: [
              if (asktoCreateLoginPin) ...[
                Container(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                  child: Column(
                    children: [
                      const Text(
                          "Create a Pin",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                      const SizedBox(height: 20.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pin1,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: InputDecoration(
                                  hintText: "0",
                                  hintStyle: const TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pin2,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pin3,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pin4,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pin5,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pin6,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 40.0,),
                      const Text(
                        "Re-enter the Pin",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      const SizedBox(height: 20.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pinToVerify1,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pinToVerify2,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pinToVerify3,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pinToVerify4,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pinToVerify5,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pinToVerify6,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Login Pin',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w700),
                          ),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[850],
                            child: IconButton(
                                color: Colors.white,
                                onPressed: () {
                                  pinCreation();
                                },
                                icon: const Icon(
                                  Icons.arrow_forward,
                                )),
                          )
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                )
              ]



              else ...[
                Container(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20.0,),
                      const Text(
                        "Enter the login Pin",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      const SizedBox(height: 30.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pin1,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: InputDecoration(
                                  hintText: "0",
                                  hintStyle: const TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pin2,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pin3,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pin4,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pin5,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 54,
                            child: TextField(
                              controller: _pin6,
                              onChanged: (value){
                                if (value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23.0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              obscureText: true,
                              obscuringCharacter: '*',
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Verify',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w700),
                          ),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[850],
                            child: IconButton(
                                color: Colors.white,
                                onPressed: () {
                                  loginSubmit();
                                },
                                icon: const Icon(
                                  Icons.arrow_forward,
                                )),
                          )
                        ],
                      ),
                      const SizedBox(height: 40.0,),
                    ],
                  ),
                )
              ]
            ],
          )
        ),
      ),
    );
  }
}

