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
    print(json);
    if(json != null){
      final data = jsonDecode(json);
      token = data['token'];
      address = data['address'];
    }
  }
  Future<void> refresh()async {
    await _initialize();
  }
}