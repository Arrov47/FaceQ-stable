import 'dart:io';
import 'package:faceq/features/auth/presentation/pages/qr_code_android.dart';
import 'package:faceq/features/auth/presentation/pages/qr_code_windows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  late FlutterSecureStorage flutterSecureStorage;

  @override
  void initState() {
    super.initState();
    _storageInit();
  }

  _storageInit() async {
    flutterSecureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return QRCodeScannerAndroid(
        flutterSecureStorage: flutterSecureStorage,
      );
    } else {
      return QRCodeScannerWindows(
        flutterSecureStorage: flutterSecureStorage,
      );
    }
  }
}





