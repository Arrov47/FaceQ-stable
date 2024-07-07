import 'dart:io';

import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/local_storage/write_credentials.dart';
import 'package:faceq/features/auth/presentation/pages/check_password_page.dart';
import 'package:faceq/sl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_utils/qr_code_utils.dart';

class QRCodeScannerAndroid extends StatefulWidget {


  const QRCodeScannerAndroid({super.key});

  @override
  State<QRCodeScannerAndroid> createState() => _QRCodeScannerAndroidState();
}

class _QRCodeScannerAndroidState extends State<QRCodeScannerAndroid> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  String? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () async {
                final result =
                await ImagePicker().pickImage(source: ImageSource.gallery);
                if (result != null && controller != null) {
                  await QrCodeUtils.decodeFrom(result.path).then((code) {
                    _checkQrCode(code, controller!);
                  });
                }
              },
              icon: const Icon(Icons.image)),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  onPressed: () async {
                    if (controller != null) {
                      await controller!.flipCamera();
                    }
                  },
                  icon: const Icon(Icons.flip_camera_ios_sharp)),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: QRView(
                overlay: QrScannerOverlayShape(
                    borderRadius: 10.0, borderColor: Colors.blue),
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16.0),
                child: (result != null)
                    ? Text(
                  maxLines: 5,
                  textAlign: TextAlign.center,
                  '$result',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontSize: 16.0),
                )
                    : Text(
                  textAlign: TextAlign.center,
                  'Просканируйте QR код которое было создано в рабочем столе вашего компьютера',
                  maxLines: 5,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontSize: 16.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        final code = scanData.code;
        _checkQrCode(code.toString(), controller);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  _checkQrCode(String? code, QRViewController controller){
    if (code != null) {
      setState(() {
        if (code.split(":")[1] == "5243") {
          result = code;
          writeAddress(code);
          controller.stopCamera();
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