import 'package:faceq/config/classes/credentials.dart';
import 'package:faceq/features/admin_panel/data/data_sources/remote_datasource.dart';
import 'package:faceq/features/admin_panel/data/repositories/report_repository_impl.dart';
import 'package:faceq/features/admin_panel/domain/repositories/report_repository.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/report/load_groups_use_case.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/report/load_report_use_case.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> syncDependencies() async {
  await syncReportPage();
}

Future<void> syncReportPage() async {
  sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage(
      aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  )));
  sl.registerSingleton(Credentials());

  sl.registerFactory<RemoteDatasource>(
      () => RemoteDatasourceImpl(credentials: sl<Credentials>()));

  sl.registerFactory<ReportRepository>(
      () => ReportRepositoryImpl(remoteDatasource: sl<RemoteDatasource>()));

  sl.registerFactory(
      () => LoadReportUseCase(reportRepository: sl<ReportRepository>()));

  sl.registerFactory(
      () => LoadGroupsUseCase(reportRepository: sl<ReportRepository>()));
}
