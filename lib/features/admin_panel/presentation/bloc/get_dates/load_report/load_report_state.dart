part of 'load_report_bloc.dart';

@immutable
sealed class LoadReportState {}

final class LoadReportInitial extends LoadReportState {}

class ReportLoading extends LoadReportState {}


class ReportLoadFailed extends LoadReportState {
  final String message;

  ReportLoadFailed({required this.message});
}


class ReportLoaded extends LoadReportState {
  final List<UserWithLog> users;

  ReportLoaded({required this.users});
}