import 'dart:convert';

import 'package:faceq/features/admin_panel/domain/use_cases/show_snackbar.dart';
import 'package:faceq/features/admin_panel/presentation/widgets/NavigationBar/NavigationSideBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:http/http.dart" as http;
class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key, required this.storageResult});

  final Map<String, dynamic> storageResult;

  static route(Map<String, dynamic> storageResult) => MaterialPageRoute(
      builder: (context) => ChangePasswordPage(storageResult: storageResult));

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Icon(
          Icons.lock_sharp,
          color: Theme.of(context).iconTheme.color,
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              if (_scaffoldKey.currentState != null) {
                _scaffoldKey.currentState!.openDrawer();
              }
            },
            icon: const Icon(Icons.menu)),
      ),
      drawer: NavigationSideBar(
        scaffoldKey: _scaffoldKey,
        storageResult: storageResult,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 100.0,
                margin: const EdgeInsets.symmetric(horizontal: 20.0,vertical:12.5),
                child: TextField(
                  style: Theme.of(context).textTheme.labelLarge,
                  controller: _oldPassword,
                  decoration: const InputDecoration(
                      hintText: "Введите старый пароль",
                      border: OutlineInputBorder()),
                ),
              ),
              Container(
                height: 100.0,
                margin: const EdgeInsets.symmetric(horizontal: 20.0,vertical:12.5),
                child: TextField(
                  style: Theme.of(context).textTheme.labelLarge,
                  controller: _newPassword,
                  decoration: const InputDecoration(
                      hintText: "Введите новый пароль",
                      helperText: "Например: 129921129",
                      border: OutlineInputBorder()),
                ),
              ),
              ElevatedButton(onPressed: ()=> _sendRequest(), child: Text("Добавить группу"))
            ],
          ),
        ),
      ),
    );
  }
  _sendRequest() {
    final context = _scaffoldKey.currentState!.context;
    try {
      print(storageResult);
      http.post(Uri.parse("http://${storageResult['address']}/changePassword"),
          body: jsonEncode({
            'token': storageResult['token'],
            'old_password': _oldPassword.text,
            'new_password': _newPassword.text,
          }),
          headers: {'Content-Type': 'application/json'}).then((response) async {
        final statusCode = response.statusCode;
        if (statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body['is_valid']) {
            showSnackBar("Пароль успешно изменён", context, Colors.green);
          } else {
            const storage = FlutterSecureStorage(
                aOptions: AndroidOptions(encryptedSharedPreferences: true));
            await storage.deleteAll();
          }
        } else {
          showSnackBar(
              "Unexpected status code: $statusCode", context, Colors.red);
        }
      },
      );
    } catch (err) {
      showSnackBar(err.toString(), context, Colors.red);
    }
  }
}
