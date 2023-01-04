import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finnone/assets/backend-api.dart' as backend;
import 'package:finnone/main/appbarwithtitle.dart';
import 'package:finnone/main/internal_server_error.dart';
import 'package:finnone/main/show_message.dart';
import 'package:finnone/main/global.dart';


class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool showSpinner = false;
  bool isBackendConnected = true;
  late String _showpage = "email";

  // Initial Selected Value
  String dropdownvalue = 'Choose ...';
  var items = [
    'Choose ...', 'Reset Password', 'Reset Pin'
  ];

  final TextEditingController _emailTextEditor = TextEditingController();
  final TextEditingController _submitEmailOtp = TextEditingController();
  final TextEditingController _passwordTextEditor = TextEditingController();

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) =>  random.nextInt(255));
    return base64UrlEncode(values);
  }

  String generateRandomOTP(int len) {
    var r = Random();
    const chars = '1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  Future<void> emailVerify() async {
    setState(() {
      showSpinner = true;
    });
    var email = _emailTextEditor.text;
    if (email.contains("@") & email.contains(".")) {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove('authVerification');
      String authToken = generateRandomOTP(6);
      print(authToken);
      await prefs.setString('authVerification', authToken);

      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST', Uri.parse(backend.EMAILVERIFY));
      request.body = json.encode({
        "email": email,
        'authToken': authToken
      });
      request.headers.addAll(headers);
      setState(() {
        showSpinner = false;
        _showpage = "submitotp";
      });
      try {
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 202) {
          Map<String,dynamic> data = jsonDecode(await response.stream.bytesToString());
          //Check Login Status
          print(data);
          if(data["errorCode"] == 1) {
            SnackBar snackBar = showMessage("Sorry !!", data["message"], Colors.redAccent, 2);
            snackbarKey.currentState?.showSnackBar(snackBar);
            setState(() {
              _showpage = "email";
            });
          }else {
            SnackBar snackBar = showMessage("〠 Check MAIL !!", "If you don't receive the OTP in next 2 minutes, \nPlease check the SPAM folder", Colors.blueGrey, 4);
            snackbarKey.currentState?.showSnackBar(snackBar);
          }
        }else {
          SnackBar snackBar = showMessage("Sorry !!", "Something bad happened at our side", Colors.redAccent, 2);
          snackbarKey.currentState?.showSnackBar(snackBar);
          setState(() {
            _showpage = "email";
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
    }else{
      SnackBar snackBar = showMessage("Wait !!", "Your email id seems wrong", Colors.redAccent, 2);
      snackbarKey.currentState?.showSnackBar(snackBar);
      setState(() {
        _showpage = "email";
      });
    }
  }


  Future<void> submitOtpVerification() async {
    setState(() {
      showSpinner = true;
    });
    var otp = _submitEmailOtp.text.toString();
    if(otp.length == 6){
      final prefs = await SharedPreferences.getInstance();
      final String? authCode = prefs.getString('authVerification');
      print(authCode);
      if(authCode==null){
        SnackBar snackBar = showMessage("Sorry !!", "Something bad happened at our side\nRetry sending the OTP", Colors.redAccent, 2);
        snackbarKey.currentState?.showSnackBar(snackBar);
        _showpage = "email";
      }else{
        if(otp == authCode){
          SnackBar snackBar = showMessage("〠 SUCCESS !!", "Now choose what to reset ... ", Colors.blueGrey, 4);
          snackbarKey.currentState?.showSnackBar(snackBar);
          _showpage = "dropdown";
        }else{
          SnackBar snackBar = showMessage("OOPs !!", "INVALID OTP", Colors.redAccent, 2);
          snackbarKey.currentState?.showSnackBar(snackBar);
        }
      }
    }else{
      SnackBar snackBar = showMessage("OOPs !!", "INVALID OTP", Colors.redAccent, 2);
      snackbarKey.currentState?.showSnackBar(snackBar);
    }

    setState(() {
      showSpinner = false;
    });
  }


  Future<void> resetPassword() async{
    setState(() {
      showSpinner = true;
    });
    var email = _emailTextEditor.text;
    if (email.contains("@") & email.contains(".")) {
      var newPassword = _passwordTextEditor.text;
      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST', Uri.parse(backend.RESETPASSWORD));
      request.body = json.encode({
        "email": email,
        "new_password": newPassword,
        "dropdownvalue": dropdownvalue
      });
      request.headers.addAll(headers);
      try {
        if(dropdownvalue=="Reset Pin" && newPassword.length != 6){
          throw "PIN SHOULD BE OF 6 DIGITS";
        }
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 202) {
          Map<String,dynamic> data = jsonDecode(await response.stream.bytesToString());
          //Check Login Status
          print(data);
          if(data["errorCode"] == 1) {
            SnackBar snackBar = showMessage("Sorry !!", data["message"], Colors.redAccent, 2);
            snackbarKey.currentState?.showSnackBar(snackBar);
          }else {
            SnackBar snackBar = showMessage("Success !!", "Password / Pin Reset Successfuly\nSign in Again with new Password / pin", Colors.blueGrey, 2);
            snackbarKey.currentState?.showSnackBar(snackBar);
            Navigator.popUntil(context, ModalRoute.withName('/sign-in'));
          }
        }else {
          SnackBar snackBar = showMessage("Sorry !!", "Something bad happened at our side", Colors.redAccent, 2);
          snackbarKey.currentState?.showSnackBar(snackBar);
        }
      }on Exception catch (exception) {
        print(exception);
        SnackBar snackBar = showMessage("Sorry !!", exception.toString(), Colors.redAccent, 2);
        snackbarKey.currentState?.showSnackBar(snackBar);
      } catch (error) {
        print(error);
        SnackBar snackBar = showMessage("Sorry !!", error.toString(), Colors.redAccent, 2);
        snackbarKey.currentState?.showSnackBar(snackBar);
      }
    }else{
      SnackBar snackBar = showMessage("Wait !!", "Your email id seems wrong\nTry restarting the process", Colors.redAccent, 2);
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
            image: AssetImage('assets/images/dashboard/register.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.2),
          appBar: CustomAppBarTitle(title: const Text('Oh NO !!'), appBar: AppBar(),),
          body: Stack(
            children: [
              if (_showpage == "email") ...[
                Container(
                  padding: const EdgeInsets.only(left: 35, top: 40),
                  child: const Text(
                    'Forgot Password/Pin ?\nEnter email ㆅ',
                    style: TextStyle(color: Colors.white, fontSize: 33),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 35, right: 35),
                          child: Column(
                            children: [
                              const SizedBox(height: 20,),
                              TextField(
                                controller: _emailTextEditor,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
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
                                        color: Colors.black,
                                      ),
                                    ),
                                    hintText: "Email",
                                    hintStyle: const TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                              ),
                              const SizedBox(height: 40),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Verify Email',
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
                                          emailVerify();
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
                      ],
                    ),
                  ),
                ),
              ]

              else if(_showpage == "submitotp")...[
                Container(
                  padding: const EdgeInsets.only(left: 35, top: 40),
                  child: const Text(
                    'Check mail & \nEnter the OTP ㆅ',
                    style: TextStyle(color: Colors.white, fontSize: 33),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 35, right: 35),
                          child: Column(
                            children: [
                              const SizedBox(height: 20,),
                              TextField(
                                enabled: false,
                                controller: _emailTextEditor,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
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
                                        color: Colors.black,
                                      ),
                                    ),
                                    hintText: "Email",
                                    hintStyle: const TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                              ),
                              const SizedBox(height: 20,),
                              TextField(
                                controller: _submitEmailOtp,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
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
                                        color: Colors.black,
                                      ),
                                    ),
                                    hintText: "OTP",
                                    hintStyle: const TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                              ),
                              const SizedBox(height: 40),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Submit OTP',
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
                                          submitOtpVerification();
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
                      ],
                    ),
                  ),
                ),
              ]


              else if(_showpage == "dropdown")...[
                Container(
                  padding: const EdgeInsets.only(left: 35, top: 40),
                  child: const Text(
                    'What to Reset ? \nPassword or Pin ⍩',
                    style: TextStyle(color: Colors.white, fontSize: 33),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 35, right: 35),
                          child: Column(
                            children: [
                              const SizedBox(height: 20,),
                              TextField(
                                enabled: false,
                                controller: _emailTextEditor,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
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
                                        color: Colors.black,
                                      ),
                                    ),
                                    hintText: "Email",
                                    hintStyle: const TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                              ),
                              const SizedBox(height: 20,),
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(color: Colors.black54),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButton(
                                  // Initial Value
                                  value: dropdownvalue,
                                  // Down Arrow Icon
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black,),
                                  // Array list of items
                                  items: items.map((String items) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Text(items, style: const TextStyle(color: Colors.black)),
                                    );
                                  }).toList(),
                                  // After selecting the desired option,it will
                                  // change button value to selected value
                                  onChanged: (String? newValue) {
                                    if (newValue != 'Choose ...'){
                                      setState(() {
                                        dropdownvalue = newValue!;
                                        _showpage = "newpassword";
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ]


                else if(_showpage == "newpassword")...[
                    Container(
                      padding: const EdgeInsets.only(left: 35, top: 40),
                      child: const Text(
                        "Don't Forget \nit now.. ಠ",
                        style: TextStyle(color: Colors.white, fontSize: 33),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 35, right: 35),
                              child: Column(
                                children: [
                                  const SizedBox(height: 20,),
                                  TextField(
                                    enabled: false,
                                    controller: _emailTextEditor,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.white),
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
                                            color: Colors.black,
                                          ),
                                        ),
                                        hintText: "Email",
                                        hintStyle: const TextStyle(color: Colors.white),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        )),
                                  ),
                                  const SizedBox(height: 20,),
                                  if(dropdownvalue == "Reset Password")...[
                                    TextField(
                                      controller: _passwordTextEditor,
                                      style: const TextStyle(color: Colors.white),
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
                                              color: Colors.black,
                                            ),
                                          ),
                                          hintText: "New Password",
                                          hintStyle: const TextStyle(color: Colors.white),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          )),
                                    ),
                                  ]else ...[
                                    TextField(
                                      controller: _passwordTextEditor,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(6),
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      style: const TextStyle(color: Colors.white),
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
                                              color: Colors.black,
                                            ),
                                          ),
                                          hintText: "New Pin",
                                          hintStyle: const TextStyle(color: Colors.white),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          )),
                                    ),
                                  ],
                                  const SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Reset',
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
                                              resetPassword();
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
                          ],
                        ),
                      ),
                    ),
                  ]



            ],
          ),
        ),
      ),
    );
  }
}
