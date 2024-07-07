part of 'load_groups_bloc.dart';

@immutable
sealed class LoadGroupsEvent {}



class LoadGroups extends LoadGroupsEvent {
  final String token;

  LoadGroups({
    required this.token,
  });
}

