import 'dart:convert';

import 'package:faceq/config/env/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> writeAddress(
    String code, FlutterSecureStorage flutterSecureStorage) async {
  final jsonData = jsonEncode({'address': code.trim()});
  await flutterSecureStorage.write(key: Env.credentialKey, value: jsonData);
}