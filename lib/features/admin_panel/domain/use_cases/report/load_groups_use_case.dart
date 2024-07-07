import 'package:dartz/dartz.dart';
import 'package:faceq/config/errors/failure.dart';
import 'package:faceq/core/usecase/usecase.dart';
import 'package:faceq/features/admin_panel/domain/repositories/report_repository.dart';

class LoadGroupsUseCase extends UseCase<List<dynamic>, LoadGroupsParams> {
  final ReportRepository reportRepository;

  LoadGroupsUseCase({required this.reportRepository});

  @override
  Future<Either<Failure, List<dynamic>>> call(LoadGroupsParams params) async {
    return await reportRepository.loadGroups(params.token);
  }
}

class LoadGroupsParams {
  final String token;

  LoadGroupsParams({required this.token});
}
