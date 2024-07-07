part of 'load_report_bloc.dart';

@immutable
sealed class LoadReportEvent {}


class LoadReport extends LoadReportEvent {
  final String token;
  final String date;
  final String groupName;

  LoadReport({
    required this.token,
    required this.date,
    required this.groupName,
  });
}