import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:frappe_dart/src/models/apps_response/message.dart';

part 'apps_event.dart';
part 'apps_state.dart';

class AppsBloc extends Bloc<AppsEvent, AppsState> {
  AppsBloc({
    required this.frappe,
  }) : super(AppsState.initial()) {
    on<LoadAppsEvent>(_onLoadAppsEvent);
  }

  final FrappeClient frappe;

  Future<void> _onLoadAppsEvent(
    LoadAppsEvent event,
    Emitter<AppsState> emit,
  ) async {
    final apps = await frappe.getApps();
    emit(state.copyWith(apps: apps.message));
  }
}
