import 'package:dartz/dartz.dart';
import 'package:faceq/config/errors/failure.dart';
import 'package:faceq/features/admin_panel/data/data_sources/remote_datasource.dart';
import 'package:faceq/features/admin_panel/domain/entities/user_with_log.dart';
import 'package:faceq/features/admin_panel/domain/repositories/report_repository.dart';
import 'package:http/http.dart' as http;

class ReportRepositoryImpl implements ReportRepository {
  final RemoteDatasource remoteDatasource;

  ReportRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, List<dynamic>>> loadGroups(
      String token) async {
    return await remoteDatasource.loadGroups(token);
  }

  @override
  Future<Either<Failure, List<UserWithLog>>> loadReport(
      String token, String date, String groupName) async {
    return await remoteDatasource.loadReport(token, date, groupName);
  }
}
