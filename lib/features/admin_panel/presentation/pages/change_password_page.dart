import 'dart:convert';

import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/core/widgets/progess_loading.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/local_storage/delete_credentials.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/show_snackbar.dart';
import 'package:faceq/features/admin_panel/presentation/widgets/NavigationBar/NavigationSideBar.dart';
import 'package:faceq/features/auth/presentation/pages/check_password_page.dart';
import 'package:faceq/sl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:http/http.dart" as http;
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  static route() => MaterialPageRoute(
      builder: (context) => ChangePasswordPage());

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _oldPassword = TextEditingController();

  final _newPassword = TextEditingController();

  final _credentials = sl<Credentials>();

  Widget requestButton = const ProgressLoading();
@override
  void initState() {
    super.initState();
    _getRequestButtonClickable();
  }
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
              requestButton
            ],
          ),
        ),
      ),
    );
  }

  _sendRequest() {
    setState(() {
      requestButton = const ProgressLoading();
    });
    final context = _scaffoldKey.currentState!.context;
    try {
      http.post(Uri.parse("http://${_credentials.address}/changePassword"),
          body: jsonEncode({
            'token': _credentials.token,
            'old_password': _oldPassword.text,
            'new_password': _newPassword.text,
          }),
          headers: {'Content-Type': 'application/json'}).then((response) async {
        final statusCode = response.statusCode;
        if (statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body['is_valid']) {
            _getRequestButtonClickable();
            showSnackBar("Пароль успешно изменён", context, Colors.green);
          } else {
            showSnackBar("Неверные данные", context, Colors.red);
            _getRequestButtonClickable();
            if(body['is_token_valid']){
              _signOut();

            }
          }
        } else {
          _getRequestButtonClickable();
          showSnackBar(
              "Unexpected status code: $statusCode", context, Colors.red);
        }
      },
      );
    } catch (err) {
      _getRequestButtonClickable();
      showSnackBar(err.toString(), context, Colors.red);
    }
  }

  _getRequestButtonClickable(){
    setState(() {
      requestButton =ElevatedButton(onPressed: ()=> _sendRequest(), child: Text("Изменить пароль"));
    });
  }
  _signOut() {
    deleteCredentials();
    Navigator.pushAndRemoveUntil(_scaffoldKey.currentState!.context,
        CheckPasswordPage.route(), (route) => false);
  }
}
