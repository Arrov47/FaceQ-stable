import 'dart:convert';

import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/core/widgets/progess_loading.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/show_snackbar.dart';
import 'package:faceq/features/admin_panel/presentation/widgets/NavigationBar/NavigationSideBar.dart';
import 'package:faceq/sl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:http/http.dart" as http;

class DeleteUserPage extends StatefulWidget {
  const DeleteUserPage({super.key});

  static route() => MaterialPageRoute(builder: (context) => DeleteUserPage());

  @override
  State<DeleteUserPage> createState() => _DeleteUserPageState();
}

class _DeleteUserPageState extends State<DeleteUserPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _userID = TextEditingController();

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
          Icons.person_remove_sharp,
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
      drawer: NavigationSideBar(scaffoldKey: _scaffoldKey),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 100.0,
                margin: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 50.0),
                child: TextField(
                  style: Theme.of(context).textTheme.labelLarge,
                  controller: _userID,
                  decoration: const InputDecoration(
                      hintText: "Введите id пользователя",
                      helperText: "Например: 12399312976838",
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
      http.post(Uri.parse("http://${_credentials.address}/deleteUser"),
          body: jsonEncode({
            'token': _credentials.token,
            'id': _userID.text,
          }),
          headers: {'Content-Type': 'application/json'}).then(
        (response) async {
          final statusCode = response.statusCode;
          if (statusCode == 200) {
            final body = jsonDecode(response.body);
            if (body['is_valid']) {
              _getRequestButtonClickable();
              showSnackBar(
                  "Пользователь успешно удалён", context, Colors.green);
            } else {
              const storage = FlutterSecureStorage(
                  aOptions: AndroidOptions(encryptedSharedPreferences: true));
              await storage.deleteAll();
            }
          } else if (statusCode == 400) {
            _getRequestButtonClickable();
            showSnackBar("Нет пользователя с таким id", context, Colors.red);
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

  _getRequestButtonClickable() {
    setState(() {
      requestButton = ElevatedButton(
          onPressed: () => _sendRequest(), child: Text("Удалить пользователя"));
    });
  }
}
