import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;
import 'package:finnone/assets/backend-api.dart' as backend;
import 'package:finnone/main/appbarwithtitle.dart';
import 'package:finnone/main/internal_server_error.dart';
import 'package:finnone/main/show_message.dart';
import 'package:finnone/main/global.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool showSpinner = false;
  bool isBackendConnected = true;

  final TextEditingController _emailTextEditor = TextEditingController();
  final TextEditingController _passwordTextEditor = TextEditingController();
  final TextEditingController _firstNameTextEditor = TextEditingController();
  final TextEditingController _lastNameTextEditor = TextEditingController();

  Future<void> postSignUp() async{
    setState(() {
      showSpinner = true;
    });
    var email = _emailTextEditor.text;
    if (email.contains("@") & email.contains(".")){
      var firstName = _firstNameTextEditor.text;
      var lastName = _lastNameTextEditor.text;
      var password = _passwordTextEditor.text;
      if(password.length >= 8){
        var headers = {
          'Content-Type': 'application/json'
        };
        var request = http.Request('POST', Uri.parse(backend.SIGNUP));
        request.body = json.encode({
          "first_name": firstName,
          "last_name": lastName,
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
            if(data["errorCode"] == 1) {
              SnackBar snackBar = showMessage("Sorry !!", data["message"], Colors.redAccent, 2);
              snackbarKey.currentState?.showSnackBar(snackBar);
            }else{
              if(data["isLogined"] == false){
                print("Sign In Failed");
                SnackBar snackBar = showMessage("Oh Snaps !!", "Invalid Email or Password", Colors.redAccent, 2);
                snackbarKey.currentState?.showSnackBar(snackBar);
              }
              else{
                Navigator.pushReplacementNamed(context, '/');
              }
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
        SnackBar snackBar = showMessage("Wait !!", "Password must be atleast 8 Characters", Colors.redAccent, 2);
        snackbarKey.currentState?.showSnackBar(snackBar);
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
              image: AssetImage('assets/images/dashboard/register.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.black.withOpacity(0.2),
            appBar: CustomAppBarTitle(title: const Text('Welcome to FinnOne !!'), appBar: AppBar(),),
            body: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 35, top: 40),
                  child: const Text(
                    'Create a Quick\nAccount ⍢',
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
                              TextField(
                                controller: _firstNameTextEditor,
                                keyboardType: TextInputType.name,
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
                                    hintText: "First Name",
                                    hintStyle: const TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                              ),
                              const SizedBox(height: 30),
                              TextField(
                                controller: _lastNameTextEditor,
                                keyboardType: TextInputType.name,
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
                                    hintText: "Last Name",
                                    hintStyle: const TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                              ),
                              const SizedBox(height: 30),
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
                              const SizedBox(height: 30),
                              TextField(
                                controller: _passwordTextEditor,
                                style: const TextStyle(color: Colors.white),
                                obscureText: true,
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
                                    hintText: "Password",
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
                                    'Sign Up',
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
                                          postSignUp();
                                        },
                                        icon: const Icon(
                                          Icons.arrow_forward,
                                        )),
                                  )
                                ],
                              ),
                              const SizedBox(height: 40),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, '/sign-in');
                                    },
                                    style: const ButtonStyle(),
                                    child: const Text(
                                      'Sign In',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Colors.white,
                                          fontSize: 18),
                                    ),
                                  ),
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

