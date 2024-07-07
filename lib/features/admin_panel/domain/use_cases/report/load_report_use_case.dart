import 'package:dartz/dartz.dart';
import 'package:faceq/config/errors/failure.dart';
import 'package:faceq/core/usecase/usecase.dart';
import 'package:faceq/features/admin_panel/domain/entities/user_with_log.dart';
import 'package:faceq/features/admin_panel/domain/repositories/report_repository.dart';

class LoadReportUseCase extends UseCase<List<UserWithLog>, LoadReportParams> {
  final ReportRepository reportRepository;

  LoadReportUseCase({required this.reportRepository});

  @override
  Future<Either<Failure, List<UserWithLog>>> call(
      LoadReportParams params) async {
    return await reportRepository.loadReport(
        params.token, params.date, params.groupName);
  }
}

class LoadReportParams {
  final String token;
  final String groupName;
  final String date;

  LoadReportParams({
    required this.token,
    required this.groupName,
    required this.date,
  });
}
