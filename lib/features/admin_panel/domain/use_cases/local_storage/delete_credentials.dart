import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> deleteCredentials() async {
  const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ));
  await storage.deleteAll();
}