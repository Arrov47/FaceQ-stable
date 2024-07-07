import 'dart:convert';
import 'package:faceq/features/admin_panel/domain/use_cases/local_storage/delete_credentials.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/show_snackbar.dart';
import 'package:faceq/features/admin_panel/presentation/widgets/NavigationBar/NavigationSideBar.dart';
import 'package:faceq/features/auth/presentation/pages/check_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DeleteGroupPage extends StatelessWidget {
  DeleteGroupPage({super.key, required this.storageResult});

  final Map<String, dynamic> storageResult;

  static route(Map<String, dynamic> storageResult) => MaterialPageRoute(
      builder: (context) => DeleteGroupPage(storageResult: storageResult));

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _groupField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Icon(
          Icons.group_remove_sharp,
          color: Theme.of(context).iconTheme.color,
        ),
        // title: Icon(Icons.group_add_sharp),
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
                height: 100,
                margin: const EdgeInsets.symmetric(horizontal: 20.0,vertical:50.0),
                child: TextField(
                  style: Theme.of(context).textTheme.labelLarge,
                  controller: _groupField,
                  decoration: const InputDecoration(
                      hintText: "Введите имя группы",
                      helperText: "Например: 11A",
                      border: OutlineInputBorder()),
                ),
              ),
              ElevatedButton(
                  onPressed: () => _sendRequest(),
                  child: const Text("Удалить группу"))
            ],
          ),
        ),
      ),
    );
  }
  _signOut() {
    deleteCredentials();
    Navigator.pushAndRemoveUntil(_scaffoldKey.currentState!.context,
        CheckPasswordPage.route(), (route) => false);
  }

  _sendRequest() {
    final context = _scaffoldKey.currentState!.context;
    try {
      http.post(Uri.parse("http://${storageResult['address']}/deleteGroup"),
          body: jsonEncode({
            'token': storageResult['token'],
            'group_name': _groupField.text,
          }),
          headers: {'Content-Type': 'application/json'}).then((response) async {
        final statusCode = response.statusCode;
        if (statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body['is_valid'] && body['is_token_valid']) {
            showSnackBar("Группа успешно удалена", context, Colors.green);
          } else if (!body['is_token_valid']) {
            const storage = FlutterSecureStorage(
                aOptions: AndroidOptions(encryptedSharedPreferences: true));
            await storage.deleteAll();
            _signOut();
          } else {
            showSnackBar(
                "Группа с таким именем не существует", context, Colors.red);
          }
        } else {
          showSnackBar(
              "Unexpected status code: $statusCode", context, Colors.red);
        }
      }, onError: (err) {
        showSnackBar(err.toString(), context, Colors.red);
      });
    } catch (err) {
      showSnackBar(err.toString(), context, Colors.red);
    }
  }


}
