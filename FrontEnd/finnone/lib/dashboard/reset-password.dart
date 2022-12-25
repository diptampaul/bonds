import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;
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
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
