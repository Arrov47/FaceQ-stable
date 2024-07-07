import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/config/errors/failure.dart';
import 'package:faceq/features/admin_panel/domain/entities/user_with_log.dart';
import 'package:faceq/sl.dart';
import 'package:http/http.dart' as http;
abstract interface class RemoteDatasource{

  Future<Either<Failure,List<dynamic>>> loadGroups(String token);
  Future<Either<Failure,List<UserWithLog>>> loadReport(String token, String groupName, String date);
}

class RemoteDatasourceImpl implements RemoteDatasource{
  final Map<String,dynamic> storageResult;

  RemoteDatasourceImpl({required this.storageResult});
  @override
  Future<Either<Failure, List<dynamic>>> loadGroups(String token)async {
    try{
        final response = await http.post(
          Uri.parse("http://${sl<Credentials>().address}/getGroups"),
          body: jsonEncode({
            'token': sl<Credentials>().token,
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
          return Left(NetworkFailure(message: "Error occurred in the client side"));
        }
    }catch(err){
      print(err.toString());
      return Left(NetworkFailure(message: "INEEEEEEEEEEEEE ${err.toString()}"));
    }
  }

  @override
  Future<Either<Failure, List<UserWithLog>>> loadReport(String token, String groupName, String date) async {
        print(jsonEncode({
          'token': storageResult['token'],
          'date': date,
          'group': groupName,
        }));
        final response = await http.post(
            Uri.parse("http://${storageResult['address']}/getDate"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'token': storageResult['token'],
              'date': date,
              'group': groupName,
            }));
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body['is_token_valid']) {
            if (body['is_valid']) {
              final data = body['data'];
              if(data != null){
                List<UserWithLog> users = [];
                for (final user in data) {
                  users.add(UserWithLog(
                      id: user[0],
                      name: user[1],
                      surname: user[2],
                      fathersName: user[3],
                      group: user[4],
                      log: user[5]));
                }
                print(users);
                return Right(users);
              }else{
                return Left(NetworkFailure(
                    message: "В заданной дате нет записов"));
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