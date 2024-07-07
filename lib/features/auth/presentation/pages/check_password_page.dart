import 'dart:convert';
import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/show_snackbar.dart';
import 'package:faceq/sl.dart';
import 'package:http/http.dart' as http;
import 'package:faceq/config/env/env.dart';
import 'package:faceq/features/admin_panel/presentation/pages/dates_page.dart';
import 'package:faceq/features/auth/presentation/pages/qr_code_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:network_info_plus/network_info_plus.dart';

class CheckPasswordPage extends StatefulWidget {
  const CheckPasswordPage({super.key});

  static route() =>
      MaterialPageRoute(builder: (context) => const CheckPasswordPage());

  @override
  State<CheckPasswordPage> createState() => _CheckPasswordPageState();
}

class _CheckPasswordPageState extends State<CheckPasswordPage> {
  final TextEditingController _password = TextEditingController();
  final info = NetworkInfo();
  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  bool suffixVisible = false;
  String? address;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkForCredentials();
  }

  _checkForCredentials() async {
    final jsonData = await storage.read(key: Env.credentialKey);
    if (jsonData != null) {
      final result = jsonDecode(jsonData) as Map<String, dynamic>;
      print(result);
      setState(() {
        address = result['address'];
      });
      if (result.containsKey('token') && result.containsKey('address')) {
        _checkAndLogin(result);
      }
    } else {
      _showAlertDialogAndNavigate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                height: 14,
                width: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: address != null ? Colors.green : Colors.red,
                ),
              ),
              Text(
                address != null
                    ? "Адрес сервера:\n $address"
                    : "Адрес сервера недоступен",
                style: Theme.of(context).textTheme.labelLarge,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
        actions: [
          IconButton(
              tooltip: "Сканировать QR код заново",
              onPressed: () {
                _navigateToQR();
              },
              icon: const Icon(Icons.track_changes))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "FaceQ",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
            child: TextFormField(
              onChanged: (val) => val.length > 1
                  ? setState(() {
                      suffixVisible = true;
                    })
                  : null,
              onEditingComplete: () => _loginUser(_password.text),
              style: Theme.of(context).textTheme.titleMedium,
              controller: _password,
              decoration: InputDecoration(
                suffixIcon: suffixVisible
                    ? IconButton(
                        onPressed: () {
                          _password.clear();
                          setState(() {
                            suffixVisible = false;
                          });
                        },
                        icon: const Icon(Icons.close))
                    : null,
                hintText: "Пароль",
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          ElevatedButton(
              onPressed: () {
                _loginUser(_password.text);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: Text("Войти"),
              ))
        ],
      ),
    ));
  }

  _navigate() {
    Navigator.pushAndRemoveUntil(context, DatesPage.route(), (route) => false);
  }

  _showAlertDialogAndNavigate() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.info_rounded,
              size: 30,
            ),
            title: const Text(
                "Чтобы ипользовать приложение вам сначало надо подключиться к серверу"),
            // content: Text(statusCode),
            actions: [
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      _navigateToQR();
                    },
                    child: const Text("Ok")),
              )
            ],
          );
        });
  }

  _badResponse(String statusCode) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
                "Проверьте подключено ли устройство к одной сети с сервером"),
            content: Text(statusCode),
            actions: [
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Ok")),
              )
            ],
          );
        });
  }

  _navigateToQR() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const QrCodePage()));
  }

  _checkAndLogin(Map<String, dynamic> result) async {
    final response = await http.post(Uri.parse("http://$address/checkToken"),
        body: jsonEncode({
          'token': result['token'],
        }),
        headers: {'Content-Type': 'application/json'});
    // final response = await dio.post("http://${result['address']}/checkToken}",
    //     data: jsonEncode({
    //       "token": result['token'],
    //     }),
    //     options: Options(
    //       headers: {"Content-Type": "application/json"},
    //     ));
    final statusCode = response.statusCode;
    if (statusCode == 200) {
      final valid = jsonDecode(response.body);
      if (valid['is_valid']) {
        _navigate();
      }
    } else {
      _badResponse("Status code: $statusCode and ${response.body}");
    }
  }

  _loginUser(String password) async {
    try {
      final response =
          await http.post(Uri.parse("http://$address/checkPassword"),
              body: jsonEncode({
                "login": "admin",
                "password": password,
              }),
              headers: {'Content-Type': 'application/json'});
      // final response = await dio.post("http://$address/checkPassword}",
      //     data: jsonEncode({
      //       "login": "admin",
      //       "password": password,
      //     }),
      //     options: Options(
      //       headers: {'Content-Type': 'application/json'},
      //     ));
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['token'] != '') {
          final data = {
            'address': address,
            'token': result['token'],
          };
          await sl<FlutterSecureStorage>()
              .write(key: Env.credentialKey, value: jsonEncode(data));
          await sl<Credentials>().refresh();

          _navigate();
        } else {
          showSnackBar("Неправильный пароль ", context, Colors.red);
        }
      } else {
        _badResponse("Status code ine: $statusCode");
      }
    } catch (err) {
      _badResponse("Message: ${err.toString()}");
    }
  }
}
