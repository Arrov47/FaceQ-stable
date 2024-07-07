import 'dart:convert';

import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/core/widgets/progess_loading.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/show_snackbar.dart';
import 'package:faceq/features/admin_panel/presentation/widgets/NavigationBar/NavigationSideBar.dart';
import 'package:faceq/sl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  static route() => MaterialPageRoute(builder: (context) => AddGroupPage());

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _groupField = TextEditingController();

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
          Icons.group_add_sharp,
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
                height: 100.0,
                margin: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 50.0),
                child: TextField(
                  style: Theme.of(context).textTheme.labelLarge,
                  controller: _groupField,
                  decoration: const InputDecoration(
                      hintText: "Введите имя группы",
                      helperText: "Например: 11A",
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
      http.post(Uri.parse("http://${_credentials.address}/addGroup"),
          body: jsonEncode({
            'token': _credentials.token,
            'group_name': _groupField.text,
          }),
          headers: {'Content-Type': 'application/json'}).then(
        (response) async {
          final statusCode = response.statusCode;
          if (statusCode == 200) {
            final body = jsonDecode(response.body);
            if (body['is_valid']) {
              _getRequestButtonClickable();
              showSnackBar("Группа успешно добавлена", context, Colors.green);
            } else {
              const storage = FlutterSecureStorage(
                  aOptions: AndroidOptions(encryptedSharedPreferences: true));
              await storage.deleteAll();
            }
          } else {
            _getRequestButtonClickable();
            showSnackBar(
                "Unexpected status code: $statusCode", context, Colors.red);
          }
        },
        //     onError: (err) {
        //   _showSnackBar(err.toString(), context, Colors.red);
        // }
      );
    } catch (err) {
      _getRequestButtonClickable();
      showSnackBar(err.toString(), context, Colors.red);
    }
  }

  _getRequestButtonClickable() {
    setState(() {
      requestButton = ElevatedButton(
          onPressed: () => _sendRequest(),
          child: const Text("Добавить группу"));
    });
  }
}
