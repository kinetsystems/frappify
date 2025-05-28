part of 'desk_bloc.dart';

abstract class DeskEvent extends Equatable {
  const DeskEvent();

  @override
  List<Object?> get props => [];
}

class LogoutEvent extends DeskEvent {
  const LogoutEvent({required this.context});

  final BuildContext context;

  @override
  List<Object?> get props => [context];
}

class LoadUserDataEvent extends DeskEvent {}

class LoadWorkspacesEvent extends DeskEvent {}

class LoadWorkspaceEvent extends DeskEvent {
  const LoadWorkspaceEvent({required this.workspaceId});

  final String workspaceId;

  @override
  List<Object?> get props => [workspaceId];
}
