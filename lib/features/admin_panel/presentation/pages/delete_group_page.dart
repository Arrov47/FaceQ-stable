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
import 'package:http/http.dart' as http;

class DeleteGroupPage extends StatefulWidget {
  const DeleteGroupPage({super.key});

  static route() => MaterialPageRoute(
      builder: (context) => DeleteGroupPage());

  @override
  State<DeleteGroupPage> createState() => _DeleteGroupPageState();
}

class _DeleteGroupPageState extends State<DeleteGroupPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _groupField = TextEditingController();

  final _credentials =sl<Credentials>();

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
              requestButton,
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
  setState(() {
    requestButton = const ProgressLoading();
  });
    final context = _scaffoldKey.currentState!.context;
    try {
      http.post(Uri.parse("http://${_credentials.address}/deleteGroup"),
          body: jsonEncode({
            'token': _credentials.token,
            'group_name': _groupField.text,
          }),
          headers: {'Content-Type': 'application/json'}).then((response) async {
        final statusCode = response.statusCode;
        if (statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body['is_valid'] && body['is_token_valid']) {
            _getRequestButtonClickable();
            showSnackBar("Группа успешно удалена", context, Colors.green);
          } else if (!body['is_token_valid']) {
            const storage = FlutterSecureStorage(
                aOptions: AndroidOptions(encryptedSharedPreferences: true));
            await storage.deleteAll();
            _signOut();
          } else {
            _getRequestButtonClickable();
            showSnackBar(
                "Группа с таким именем не существует", context, Colors.red);
          }
        } else {
          _getRequestButtonClickable();
          showSnackBar(
              "Unexpected status code: $statusCode", context, Colors.red);
        }
      }, onError: (err) {
        _getRequestButtonClickable();
        showSnackBar(err.toString(), context, Colors.red);
      });
    } catch (err) {
      _getRequestButtonClickable();
      showSnackBar(err.toString(), context, Colors.red);
    }
  }
  _getRequestButtonClickable(){
  setState(() {
    requestButton = ElevatedButton(
        onPressed: () => _sendRequest(),
        child: const Text("Удалить группу"));
  });
  }
}
