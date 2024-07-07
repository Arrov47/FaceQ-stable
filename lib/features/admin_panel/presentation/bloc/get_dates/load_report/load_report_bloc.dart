import 'package:bloc/bloc.dart';
import 'package:faceq/features/admin_panel/domain/entities/user_with_log.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/report/load_report_use_case.dart';
import 'package:meta/meta.dart';

part 'load_report_event.dart';
part 'load_report_state.dart';

class LoadReportBloc extends Bloc<LoadReportEvent, LoadReportState> {
  final LoadReportUseCase _loadReportUseCase;
  LoadReportBloc(this._loadReportUseCase) : super(LoadReportInitial()) {
    on<LoadReport>((event, emit) async {
      emit(ReportLoading());
      try {
        final result = await _loadReportUseCase.reportRepository
            .loadReport(event.token, event.groupName, event.date);
        result.fold((failure) {
          emit(ReportLoadFailed(message: failure.message));
        }, (users) {
          emit(ReportLoaded(users: users));
        });
      } catch (err) {
        print(err.toString());
        emit(ReportLoadFailed(message: err.toString()));
      }
    });
  }
}
