import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomAppBarTitle extends StatelessWidget implements PreferredSizeWidget{
  final Color backgroundColor = Colors.red;
  final Text title;
  final AppBar appBar;

  const CustomAppBarTitle({super.key, required this.title, required this.appBar});


  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[850]?.withOpacity(0.1),
      centerTitle: true,
      title: title,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}

