part of 'load_groups_bloc.dart';

@immutable
sealed class LoadGroupsState {}

final class LoadGroupsInitial extends LoadGroupsState {}

class GroupsLoaded extends LoadGroupsState {
  final List<dynamic> groups;

  GroupsLoaded({required this.groups});
}

class GroupsLoadFailed extends LoadGroupsState {
  final String message;

  GroupsLoadFailed({required this.message});
}

class GroupsLoading extends LoadGroupsState {}
