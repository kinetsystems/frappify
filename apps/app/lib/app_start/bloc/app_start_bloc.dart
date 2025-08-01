import 'dart:async';

import 'package:app_logger/app_logger.dart';
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
    : super(AppStartState.initial()) {
    on<StartCookieCheckUpEvent>(_onStartCookieCheckUp);
    on<StopCookieCheckUpEvent>(_onStopCookieCheckUp);
    on<ExpiredLogoutEvent>(_onLogout);

    //Start Periodical cookie expire check up
    timer = Timer.periodic(const Duration(seconds: cookieExpCheckingIntInSec), (
      timer,
    ) async {
      try {
        frappe.cookie = await secureStorage.read(key: 'cookie');
        add(const StartCookieCheckUpEvent());
      } catch (e) {
        // Handle storage read failure gracefully
        await AppLogger.reportError(
          'Failed to read cookie from secure storage: $e',
        );
        // Only dispatch event if we have a valid cookie
        if (frappe.cookie != null) {
          add(const StartCookieCheckUpEvent());
        }
      }
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
      emit(state.copyWith(isLoggedIn: false, isCookieTimedOut: false));
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
              isLoggedIn: false,
              message: 'Your session has expired.',
            ),
          );
        } else {
          final diff = expiryDate.difference(currentUtcTime);
          if (diff.inSeconds < cookieExpWarningInSec) {
            emit(
              state.copyWith(
                isCookieTimedOut: false,
                isLoggedIn: true,
                message:
                    'Your session will expire in ${formatDuration(diff.inSeconds)}',
                time: diff.inSeconds,
              ),
            );
          }
        }
      } catch (e) {
        emit(state.copyWith(isLoggedIn: false, isCookieTimedOut: false));
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

    emit(state.copyWith(isLoggedIn: false, isCookieTimedOut: false));

    await event.navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _onStopCookieCheckUp(
    StopCookieCheckUpEvent event,
    Emitter<AppStartState> emit,
  ) async {
    timer?.cancel();
  }

  @override
  Future<void> close() {
    timer?.cancel();

    return super.close();
  }
}
