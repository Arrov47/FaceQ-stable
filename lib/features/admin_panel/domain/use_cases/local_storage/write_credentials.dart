import 'dart:convert';

import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/config/env/env.dart';
import 'package:faceq/sl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> writeAddress(
    String code) async {
  final jsonData = jsonEncode({'address': code.trim()});
  await sl<FlutterSecureStorage>().write(key: Env.credentialKey, value: jsonData);
}