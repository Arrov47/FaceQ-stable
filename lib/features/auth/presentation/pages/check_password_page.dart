import 'package:faceq/features/auth/presentation/pages/dates_page.dart';
import 'package:flutter/material.dart';

class CheckPasswordPage extends StatefulWidget {
  const CheckPasswordPage({super.key});

  @override
  State<CheckPasswordPage> createState() => _CheckPasswordPageState();
}

class _CheckPasswordPageState extends State<CheckPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "FaceQ",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Пароль",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  DatesPage.route(),
                  (route) => false,
                );
              },
              child: Text("Войти"))
        ],
      ),
    ));
  }
}
