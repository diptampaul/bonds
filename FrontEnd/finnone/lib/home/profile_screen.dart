import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:finnone/assets/backend-api.dart' as backend;
import 'package:finnone/assets/constants.dart';
import 'package:finnone/main/show_message.dart';
import 'package:finnone/main/global.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool showSpinner = false;
  late String loginToken;
  late String imageUrl = "${BACKEND_URL}media/dashboard/user_photo/Icon.png";
  late String emailId = "support@finnone.in";
  late String firstName = "FinnOne";
  late String walletBalance = "0.0";

  Future getLoginStatus() async{
    setState(() {
      showSpinner = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final String? loginToken = prefs.getString('loginToken');
    print(loginToken);
    if(loginToken==null){
      Navigator.pushReplacementNamed(context, '/sign-in');
    }

    // Load Data
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse(backend.PROFILE));
    request.body = json.encode({
      "login_token": loginToken
    });
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 202) {
        Map<String,dynamic> data = jsonDecode(await response.stream.bytesToString());
        //Check Login Status
        print(data);
        if(data["errorCode"] == 1){
          SnackBar snackBar = showMessage("Oh Snaps !!", data["message"].toString(), Colors.redAccent, 2);
          snackbarKey.currentState?.showSnackBar(snackBar);
        }else{
          imageUrl = "${BACKEND_URL}media/${data['image_url']}";
          emailId =  data['email'].toString();
          firstName = data['first_name'].toString();
          walletBalance = data['wallet_balance'].toString();
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
    setState(()
    {
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
          backgroundColor: Colors.white70,
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            children: [
              const SizedBox(height: 20.0,),
              Column(
                children: [
                  Text(
                    "Hi ${firstName} !!",
                    style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  const SizedBox(height: 2.0,),
                  const Divider(color: Colors.grey, thickness: 1.0,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                image: DecorationImage(
                                    image: NetworkImage(imageUrl)
                                )
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const SizedBox(height: 5.0,),
                          const Text("Fund Balance", style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            fontFamily: "MartianMono"
                          )),
                          const SizedBox(height: 15.0,),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: Colors.grey[200]
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3.0),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF526799),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.currency_rupee_rounded, color: Colors.white, size: 18,),
                                    ),
                                    const SizedBox(width: 10.0,),
                                    Text(
                                      walletBalance,
                                      style: TextStyle(
                                        color: Color(0xFF526799),
                                        fontWeight: FontWeight.w600
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8.0,),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3.0),
                                      decoration: const BoxDecoration(
                                        color: Colors.black87,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add, color: Colors.white, size: 18,),
                                    ),
                                    const SizedBox(width: 10.0,),
                                    const Text(
                                      "Add Fund",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: (){
                          print("Show History");
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children:
                          const [
                            SizedBox(height: 5.0,),
                            Icon(Icons.history, color: Colors.black87, size: 24,),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        )
    );
  }
}
