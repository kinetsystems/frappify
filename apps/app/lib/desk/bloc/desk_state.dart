part of 'desk_bloc.dart';

class DeskState extends Equatable {
  const DeskState({
    this.userId,
    this.username,
    this.workspaces,
    this.currentWorkspace,
    this.workspace,
    this.isLoadingWorkspace = false,
  });

  factory DeskState.initial() => const DeskState();

  final String? userId;
  final String? username;
  final List<DeskPage>? workspaces;
  final String? currentWorkspace;
  final Message? workspace;
  final bool isLoadingWorkspace;

  DeskState copyWith({
    String? userId,
    String? username,
    List<DeskPage>? workspaces,
    String? currentWorkspace,
    Message? workspace,
    bool? isLoadingWorkspace,
  }) => DeskState(
    userId: userId ?? this.userId,
    username: username ?? this.username,
    workspaces: workspaces ?? this.workspaces,
    currentWorkspace: currentWorkspace ?? this.currentWorkspace,
    workspace: workspace ?? this.workspace,
    isLoadingWorkspace: isLoadingWorkspace ?? this.isLoadingWorkspace,
  );
  @override
  List<Object?> get props => [
    userId,
    username,
    workspaces,
    currentWorkspace,
    workspace,
    isLoadingWorkspace,
  ];
}
