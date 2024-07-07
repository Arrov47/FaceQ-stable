import 'package:faceq/sl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> deleteCredentials() async {
  final storage = sl<FlutterSecureStorage>();
  await storage.deleteAll();
}