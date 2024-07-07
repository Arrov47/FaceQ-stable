import 'package:dartz/dartz.dart';
import 'package:faceq/config/errors/failure.dart';
import 'package:faceq/features/admin_panel/domain/entities/user_with_log.dart';

abstract interface class ReportRepository {
  Future<Either<Failure,List<dynamic>>>loadGroups(String token);
  Future<Either<Failure,List<UserWithLog>>> loadReport(String token, String date, String groupName);
}