import 'package:faceq/features/admin_panel/domain/use_cases/local_storage/delete_credentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

List<Widget> NavigationItemBuilder(IconData icon, String title,
    {required MaterialPageRoute route, required BuildContext context,signOut = false} ) {
  return [
    InkWell(
        onTap: () {
          if (signOut) {
            deleteCredentials();
            Navigator.pushAndRemoveUntil(context, route, (route) => false);
          } else {
            Navigator.pushAndRemoveUntil(context, route, (route) => false);
          }
        },
        customBorder: const RoundedRectangleBorder(),
        child: ListTile(
          // contentPadding: EdgeInsets.all(5.0),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: Icon(icon),
        ))
  ];
}

