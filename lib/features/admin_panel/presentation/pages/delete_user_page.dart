import 'dart:convert';

import 'package:faceq/features/admin_panel/domain/use_cases/show_snackbar.dart';
import 'package:faceq/features/admin_panel/presentation/widgets/NavigationBar/NavigationSideBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:http/http.dart" as http;
class DeleteUserPage extends StatelessWidget {
  DeleteUserPage({super.key, required this.storageResult});

  final Map<String, dynamic> storageResult;

  static route(Map<String, dynamic> storageResult) => MaterialPageRoute(
      builder: (context) => DeleteUserPage(storageResult: storageResult));

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
final _userID = TextEditingController();
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
      drawer: NavigationSideBar(
          scaffoldKey: _scaffoldKey, storageResult: storageResult),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 100.0,
                margin: const EdgeInsets.symmetric(horizontal: 20.0,vertical:50.0),
                child: TextField(
                  style: Theme.of(context).textTheme.labelLarge,
                  controller: _userID,
                  decoration: const InputDecoration(
                      hintText: "Введите id пользователя",
                      helperText: "Например: 12399312976838",
                      border: OutlineInputBorder()),
                ),
              ),
              ElevatedButton(onPressed: ()=> _sendRequest(), child: Text("Удалить пользователя"))
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
      http.post(Uri.parse("http://${storageResult['address']}/deleteUser"),
          body: jsonEncode({
            'token': storageResult['token'],
            'id': _userID.text,
          }),
          headers: {'Content-Type': 'application/json'}).then((response) async {
        final statusCode = response.statusCode;
        if (statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body['is_valid']) {
            showSnackBar("Пользователь успешно удалён", context, Colors.green);
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
