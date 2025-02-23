import 'dart:io';

import 'package:faceq/features/admin_panel/domain/use_cases/local_storage/write_credentials.dart';
import 'package:faceq/features/auth/presentation/pages/check_password_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class QRCodeScannerWindows extends StatefulWidget {
  const QRCodeScannerWindows({super.key});

  @override
  State<QRCodeScannerWindows> createState() => _QRCodeScannerWindowsState();
}

class _QRCodeScannerWindowsState extends State<QRCodeScannerWindows> {
  File? _image;
  String? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  ImagePicker()
                      .pickImage(source: ImageSource.gallery)
                      .then((result) async {
                    if (result != null) {
                      setState(() {
                        _image = File(result.path);
                      });
                      // print(Platform.resolvedExecutable
                      //     .replaceFirst("faceq.exe", "windows_qr.exe"));
                      final absolutePath = Platform.resolvedExecutable
                          .replaceFirst("faceq.exe", "windows_qr.exe")
                          .replaceAll("\\", '/');
                      // final absolutePath =
                      //     Directory.current.path.replaceAll("\\", '/');
                      print(absolutePath);
                      var processResult = await Process.run(absolutePath, [
                        _image!.path.replaceAll("\\", "/"),
                      ]);
                      final code = processResult.stdout.toString();
                      _checkQrCode(code);
                    }
                  });
                },
                child: const Text("Выбрать изоброжение с QR кодом")),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _image == null
                        ? "Изоброжение не выбрано"
                        : "Изоброжение выбрано",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  _image == null
                      ? const Icon(
                          Icons.close,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(30),
              child: Text(
                result ?? "QR код не сканирован",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            )
          ],
        ),
      ),
    );
  }

  _checkQrCode(String? code) {
    if (code != null) {
      setState(() {
        if (code.split(":")[1].trim() == "5243") {
          result = code;
          writeAddress(code);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const CheckPasswordPage()),
              (route) => false);
        } else {
          result = "Не тот QR код";
        }
      });
    }
  }
}
