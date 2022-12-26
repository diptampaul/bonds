import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  final Color backgroundColor = Colors.red;
  final Text title;
  final AppBar appBar;

  const CustomAppBar({super.key, required this.title, required this.appBar});


  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[850],
      title: title,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: (){
            //action for search icon button
          },
        ),

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
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}

