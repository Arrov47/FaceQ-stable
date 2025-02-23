import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/config/errors/failure.dart';
import 'package:faceq/features/admin_panel/domain/entities/user_with_log.dart';
import 'package:http/http.dart' as http;

abstract interface class RemoteDatasource {
  Future<Either<Failure, List<dynamic>>> loadGroups(String token);
  Future<Either<Failure, List<UserWithLog>>> loadReport(
      String token, String groupName, String date);
}

class RemoteDatasourceImpl implements RemoteDatasource {
  final Credentials credentials;

  _refresh() async {
    await credentials.refresh();
  }

  RemoteDatasourceImpl({required this.credentials});
  @override
  Future<Either<Failure, List<dynamic>>> loadGroups(String token) async {
    print("CREDENTIALS: ${credentials.address}, ${credentials.token}");
    _refresh();
    try {
      final response = await http.post(
        Uri.parse("http://${credentials.address}/getGroups"),
        body: jsonEncode({
          'token': credentials.token,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final body = jsonDecode(response.body);
        if (!body['is_token_valid']) {
          print(body);
          return Left(InvalidTokenFailure(message: "Invalid token"));
        } else {
          return Right(body['groups']);
        }
      } else {
        return Left(
            NetworkFailure(message: "Error occurred in the client side"));
      }
    } catch (err) {
      print(err.toString());
      return Left(NetworkFailure(message: "INEEEEEEEEEEEEE ${err.toString()}"));
    }
  }

  @override
  Future<Either<Failure, List<UserWithLog>>> loadReport(
      String token, String groupName, String date) async {
    _refresh();
    print(jsonEncode({
      'token': credentials.token,
      'date': date,
      'group': groupName,
    }));
    final response =
        await http.post(Uri.parse("http://${credentials.address}/getDate"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'token': credentials.token,
              'date': date,
              'group': groupName,
            }));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      // print(body);
      if (body['is_token_valid']) {
        if (body['is_valid']) {
          final data = body['data'];
          if (data != null) {
            (data as Map<String, dynamic>);
            List<UserWithLog> users = [];
            print("THis is data: ${data}");
            for (final key in data.keys) {
              users.add(UserWithLog(
                  id: key,
                  name: data[key][0],
                  surname: data[key][1],
                  fathersName: data[key][2],
                  group: data[key][3],
                  log: data[key][4]));
            }
            print(users);
            return Right(users);
          } else {
            return Left(NetworkFailure(message: "В заданной дате нет записов"));
          }
        } else {
          return Left(NetworkFailure(
              message: "Internal server error: invalid operation"));
        }
      } else {
        return Left(InvalidTokenFailure(message: "Invalid token"));
      }
    } else {
      return Left(NetworkFailure(
          message: "Unexpected status code:${response.statusCode} "));
    }
  }
}
