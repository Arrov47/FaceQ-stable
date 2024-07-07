import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/features/admin_panel/data/data_sources/remote_datasource.dart';
import 'package:faceq/features/admin_panel/data/repositories/report_repository_impl.dart';
import 'package:faceq/features/admin_panel/domain/repositories/report_repository.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/report/load_groups_use_case.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/report/load_report_use_case.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

syncDependencies() async{
  await syncReportPage();
}

syncReportPage() async {
  sl.registerSingleton<Credentials>(Credentials());

  sl.registerFactory<RemoteDatasource>(() => RemoteDatasourceImpl(
          storageResult: {
            'address': sl<Credentials>().address,
            'token': sl<Credentials>().token
          }));

  sl.registerFactory<ReportRepository>(
      () => ReportRepositoryImpl(remoteDatasource: sl<RemoteDatasource>()));

  sl.registerFactory(
      () => LoadReportUseCase(reportRepository: sl<ReportRepository>()));

  sl.registerFactory(
      () => LoadGroupsUseCase(reportRepository: sl<ReportRepository>()));


}
