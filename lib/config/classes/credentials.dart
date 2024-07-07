import 'dart:convert';
import 'package:faceq/config/env/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Credentials {
  String address = '';
  String token= '';
  Credentials(){
    _initialize();
  }

  Future<void>_initialize()async{
    const storage =  FlutterSecureStorage(aOptions: AndroidOptions(
        encryptedSharedPreferences: true
    ));
    final json = await storage.read(key: Env.credentialKey);
    final data = jsonDecode(json!);
    token = data['token'];
    address = data['address'];
  }
}