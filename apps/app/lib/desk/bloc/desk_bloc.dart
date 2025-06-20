import 'package:app_logger/app_logger.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:frappe_dart/src/models/desk_sidebar_items_response/desk_page.dart';
import 'package:frappe_dart/src/models/desktop_page_request.dart';
import 'package:frappe_dart/src/models/desktop_page_response/message.dart';
import 'package:frappify/login/login.dart';
import 'package:secure_storage/secure_storage.dart';

part 'desk_event.dart';
part 'desk_state.dart';

class DeskBloc extends Bloc<DeskEvent, DeskState> {
  DeskBloc({required this.frappe, required this.secureStorage})
    : super(DeskState.initial()) {
    on<LogoutEvent>(_onLogout);
    on<LoadUserDataEvent>(_onLoadUserData);
    on<LoadWorkspacesEvent>(_onLoadWorkspaces);
    on<LoadWorkspaceEvent>(_onLoadWorkspace);
  }

  final FrappeClient frappe;
  final SecureStorage secureStorage;

  Future<void> _onLogout(LogoutEvent event, Emitter<DeskState> emit) async {
    try {
      final navigator = Navigator.of(event.context);

      await frappe.logout();
      await secureStorage.delete(key: 'cookie');
      await secureStorage.delete(key: 'username');
      await secureStorage.delete(key: 'userId');

      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e, stack) {
      await AppLogger.reportError(e, stack, 'Failed to logout');
    }
  }

  Future<void> _onLoadUserData(
    LoadUserDataEvent event,
    Emitter<DeskState> emit,
  ) async {
    try {
      final userId = await secureStorage.read(key: 'userId');
      final username = await secureStorage.read(key: 'username');
      emit(state.copyWith(userId: userId, username: username));
    } catch (e, stack) {
      await AppLogger.reportError(e, stack, 'Failed to load user data');
    }
  }

  Future<void> _onLoadWorkspaces(
    LoadWorkspacesEvent event,
    Emitter<DeskState> emit,
  ) async {
    try {
      final workspaces = await frappe.getDeskSideBarItems();
      emit(state.copyWith(workspaces: workspaces.message!.pages));
      add(LoadWorkspaceEvent(workspaceId: workspaces.message!.pages![0].name!));
    } catch (e, stack) {
      await AppLogger.reportError(e, stack, 'Failed to load workspaces');
    }
  }

  Future<void> _onLoadWorkspace(
    LoadWorkspaceEvent event,
    Emitter<DeskState> emit,
  ) async {
    try {
      // Set loading state to true
      emit(state.copyWith(isLoadingWorkspace: true));

      final workspace = await frappe.getDesktopPage(
        DesktopPageRequest(name: event.workspaceId),
      );
      emit(
        state.copyWith(
          workspace: workspace.message,
          currentWorkspace: event.workspaceId,
          isLoadingWorkspace: false,
        ),
      );
    } catch (e, stack) {
      // Set loading state to false on error
      emit(state.copyWith(isLoadingWorkspace: false));
      await AppLogger.reportError(e, stack, 'Failed to load workspace');
    }
  }
}
