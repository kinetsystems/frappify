import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:frappify/login/login.dart';
import 'package:frappify/utils/constants.dart';
import 'package:frappify/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:secure_storage/secure_storage.dart';

part 'app_start_event.dart';
part 'app_start_state.dart';

class AppStartBloc extends Bloc<AppStartEvent, AppStartState> {
  AppStartBloc({required this.secureStorage, required this.frappe})
    : super(const AppStartState()) {
    //
    on<StartCookieCheckUpEvent>(_onStartCookieCheckUp);
    on<StopCookieCheckUpEvent>(_onStopCookieCheckUp);
    on<ExpiredLogoutEvent>(_onLogout);

    //Start Periodical cookie expire check up
    timer = Timer.periodic(const Duration(seconds: cookieExpCheckingIntInSec), (
      timer,
    ) async {
      frappe.cookie = await secureStorage.read(key: 'cookie');
      add(const StartCookieCheckUpEvent());
    });
  }

  final FrappeClient frappe;
  final SecureStorage secureStorage;
  Timer? timer;

  Future<void> _onStartCookieCheckUp(
    StartCookieCheckUpEvent event,
    Emitter<AppStartState> emit,
  ) async {
    final cookie = frappe.cookie;

    if (cookie == null || cookie.isEmpty) {
      emit(state.copyWith(isCookieTimedOut: true));
      return;
    }

    final expiryMatch = RegExp('Expires=([^;]+)').firstMatch(cookie);
    if (expiryMatch != null) {
      final expiryString = expiryMatch.group(1)?.trim();

      try {
        final expiryDate = DateFormat(
          "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
        ).parseUtc(expiryString!);
        final currentUtcTime = DateTime.now().toUtc();

        if (currentUtcTime.isAfter(expiryDate)) {
          emit(
            state.copyWith(
              isCookieTimedOut: true,
              //todo locale
              message: 'Your session has expired.',
            ),
          );
        } else {
          final diff = expiryDate.difference(currentUtcTime);
          if (diff.inSeconds < cookieExpWarningInSec) {
            emit(
              state.copyWith(
                isCookieTimedOut: false,
                //todo locale
                message:
                    'Your session will in. ${formatDuration(diff.inSeconds)}',
                time: diff.inSeconds,
              ),
            );
          }
        }
      } catch (e) {
        emit(state.copyWith(isCookieTimedOut: true));
      }
    }
  }

  Future<void> _onLogout(
    ExpiredLogoutEvent event,
    Emitter<AppStartState> emit,
  ) async {
    await frappe.logout();
    await secureStorage.delete(key: 'cookie');
    await secureStorage.delete(key: 'username');
    await secureStorage.delete(key: 'userId');

    await event.navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _onStopCookieCheckUp(
    StopCookieCheckUpEvent event,
    Emitter<AppStartState> emit,
  ) async {
    timer?.cancel();
    return;
  }

  @override
  Future<void> close() {
    if (timer != null) {
      timer!.cancel();
    }

    return super.close();
  }
}
