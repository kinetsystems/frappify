import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:frappify/services/toast_service.dart';
import 'package:ntp/ntp.dart';
import 'package:secure_storage/secure_storage.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({
    required this.frappe,
    required this.secureStorage,
  }) : super(OnboardingState.initial()) {
    on<CompleteOnboardingEvent>(_onCompleteOnboardingEvent);
  }

  final SecureStorage secureStorage;
  final FrappeClient frappe;
  final List<Locale> lang = [
    const Locale('en'),
    const Locale('ar'),
  ];

  Future<void> _onCompleteOnboardingEvent(
    CompleteOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final originalAddress = await secureStorage.read(key: 'host_address');
    final oldBaseUrl = frappe.baseUrl;
    emit(state.copyWith(isLoading: true));

    try {
      final ntpTime = await NTP.now();
      final deviceTime = DateTime.now();

      final difference = deviceTime.difference(ntpTime).inMinutes.abs();

      if (difference > 3) {
        ToastService.showErrorToast(
          message:
          'Your device date or time appears incorrect. Please update it to continue.',
        );
        emit(state.copyWith(isLoading: false));
        return;
      }

      frappe.baseUrl = event.hostAddress;

      final pingResponse = await frappe.ping();

      await secureStorage.write(key: 'host_address', value: event.hostAddress);
      await secureStorage.write(key: 'completedOnboarding', value: 'true');

      emit(
        state.copyWith(
          onboardingCompleted: true,
          isLoading: false,
        ),
      );

      ToastService.showSuccessToast(
        message: 'Onboarding completed and server is reachable.',
      );
    } catch (e) {
      frappe.baseUrl = originalAddress ?? oldBaseUrl;

      emit(state.copyWith(isLoading: false));

      ToastService.showErrorToast(
        message: 'Failed to connect to the host address: ${e.toString()}',
      );
    }
  }
}
