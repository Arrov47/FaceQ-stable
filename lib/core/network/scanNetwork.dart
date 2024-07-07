import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';

// Future<void> scanNetwork() async {
//   final NetworkInfo _networkInfo = NetworkInfo();
//   final localIP = await _networkInfo.getWifiIP();
//   final subnet = await _networkInfo.getWifiSubmask();
//   print("It is IP:$localIP, \n It is subnet:$subnet");
//
//   for(var interface in await NetworkInterface.list()){
//     print("Imterface ${interface.name}");
//     for(var address in interface.addresses){
//       print(' Address ${address.address}, Type:${address.type.name}');
//     }
//   }
//
// }