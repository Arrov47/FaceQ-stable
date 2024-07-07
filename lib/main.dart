import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:faceq/config/themes/themes.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/report/load_groups_use_case.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/report/load_report_use_case.dart';
import 'package:faceq/features/admin_panel/presentation/bloc/get_dates/load_groups/load_groups_bloc.dart';
import 'package:faceq/features/admin_panel/presentation/bloc/get_dates/load_report/load_report_bloc.dart';
import 'package:faceq/features/auth/presentation/pages/check_password_page.dart';
import 'package:faceq/sl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await syncDependencies();
  final connectivityResult = await Connectivity().checkConnectivity();
  final networkInfo = NetworkInfo();
  runApp(MyApp(
    connectivityResult: connectivityResult,
    networkInfo: networkInfo,
  ));
}

class MyApp extends StatelessWidget {
  final List<ConnectivityResult> connectivityResult;
  final NetworkInfo networkInfo;

  const MyApp({
    super.key,
    required this.connectivityResult,
    required this.networkInfo,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => LoadGroupsBloc(sl<LoadGroupsUseCase>())),
        BlocProvider(
            create: (context) => LoadReportBloc(sl<LoadReportUseCase>())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FaceQ',
        theme: light,
        darkTheme: dark,
        home: const CheckPasswordPage(),
      ),
    );
  }
}
