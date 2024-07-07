import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:faceq/config/errors/failure.dart';
import 'package:faceq/features/auth/domain/entities/network_state.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class RemoteDataSource {
  Future<Either<Failure, NetworkState>> scanNetworks();

  Future<Either<Failure, String>> checkPassword(String password);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final NetworkInfo _networkInfo;
  final List<ConnectivityResult> _connectivityResult;
  final Dio dio;

  RemoteDataSourceImpl({
    required this.dio,
    required NetworkInfo networkInfo,
    required List<ConnectivityResult> connectivityResult,
  })  : _networkInfo = networkInfo,
        _connectivityResult = connectivityResult;

  @override
  Future<Either<Failure, NetworkState>> scanNetworks() async {
    if (_connectivityResult.contains(ConnectivityResult.wifi)) {
      final ipAddress = await _networkInfo.getWifiIP();
      return ipAddress != null
          ? right(
              NetworkState(
                  message: "Подключено к $ipAddress", address: ipAddress),
            )
          : left(NetworkFailure(message: "Can't get Wifi IP address "));
    } else if (_connectivityResult.contains(ConnectivityResult.ethernet)) {
      final ipAddress = await _networkInfo.getWifiGatewayIP();
      return right(
        NetworkState(message: "Подключено к $ipAddress", address: ipAddress),
      );
    } else if (_connectivityResult.contains(ConnectivityResult.mobile) &&
        Platform.isAndroid) {
      NetworkInterface? expectedInterface;
      for (var interface in await NetworkInterface.list()) {
        if (interface.name == 'wlan0') {
          expectedInterface = interface;
        }
      }
      if (expectedInterface != null &&
          expectedInterface.addresses.toList().first.type.name == "IPv4") {
        final ipAddress = expectedInterface.addresses.toList().first.address;
        return right(NetworkState(
            message: "Подключено к $ipAddress", address: ipAddress));
      } else {
        return left(NetworkFailure(message: "Can't find 'wlan0' interface"));
      }
    } else if (_connectivityResult.contains(ConnectivityResult.none)) {
      return left(NetworkFailure(message: "Подключитесь к серверу "));
    } else {
      return left(NetworkFailure(message: "Unexpected network failure"));
    }
  }

  @override
  Future<Either<Failure, String>> checkPassword(String password) async {
    final result = await scanNetworks();
    result.fold((failure) {
      return left(failure);
    }, (data) async {
      final jsonData = json.encode({
        'login': "admin",
        'password': password,
      });
      final response = await dio.post(
          'http://192.168.100.15:5243/checkPassword',
          data: jsonData,
          options: Options(headers: {'Content-Type': 'application/json'}));
      if(response.statusCode == 200){
        return right(json.decode(response.data)['token']);
      }else{
        return left(NetworkFailure(message: "Unexpected status code: ${response.statusCode}"));
      }
    });
    return left(NetworkFailure(message: "Unexpected error"));
  }
}
