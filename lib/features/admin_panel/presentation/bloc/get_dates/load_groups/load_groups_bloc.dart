import 'package:bloc/bloc.dart';
import 'package:faceq/features/admin_panel/domain/use_cases/report/load_groups_use_case.dart';
import 'package:meta/meta.dart';

part 'load_groups_event.dart';
part 'load_groups_state.dart';

class LoadGroupsBloc extends Bloc<LoadGroupsEvent, LoadGroupsState> {

  final LoadGroupsUseCase _loadGroupsUseCase;
  LoadGroupsBloc(this._loadGroupsUseCase) : super(LoadGroupsInitial()) {
    on<LoadGroups>((event, emit) async {
      emit(GroupsLoading());
      try {
        final result = await _loadGroupsUseCase.reportRepository
            .loadGroups(event.token);
        result.fold((failure) {
          emit(GroupsLoadFailed(message: failure.message));
        }, (groups) {
          emit(GroupsLoaded(groups: groups));
        });
      } catch (err) {
        emit(GroupsLoadFailed(message: "Something went wrong with loading groups"));
      }
    });
  }
}
