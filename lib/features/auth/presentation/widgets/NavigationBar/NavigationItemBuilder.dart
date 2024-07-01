import 'package:flutter/material.dart';

List<Widget> NavigationItemBuilder(IconData icon, String title,
     {MaterialPageRoute? route,BuildContext? context}) {
  return [
    InkWell(
        onTap: () {
          if (route != null && context != null) {
            Navigator.pushAndRemoveUntil(context, route, (route) => false);
            // Navigator.pop(context);
          }
          else{
            print("VYHOD");
          }
        },
        customBorder: RoundedRectangleBorder(),
        child: ListTile(
          // contentPadding: EdgeInsets.all(5.0),
          title: Text(title),
          leading: Icon(icon),
        ))
  ];
}
