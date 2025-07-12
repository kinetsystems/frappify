import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:frappify/services/toast_service.dart';
import 'package:ntp/ntp.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_config_event.dart';
part 'app_config_state.dart';

class AppConfigBloc extends Bloc<AppConfigEvent, AppConfigState> {
  AppConfigBloc({
    required this.frappe,
    required this.secureStorage,
  }) : super(AppConfigState.initial()) {
    on<SubmitHostAddressEvent>(_onSubmitHostAddress);
  }

  final FrappeClient frappe;
  final SecureStorage secureStorage;

  Future<void> _onSubmitHostAddress(
    SubmitHostAddressEvent event,
    Emitter<AppConfigState> emit,
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
      emit(state.copyWith(isLoading: false));
      ToastService.showSuccessToast(
        message: 'Host address changed successfully and server is reachable',
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      frappe.baseUrl = originalAddress ?? oldBaseUrl;

      ToastService.showErrorToast(
        message: 'Failed to connect to the new host address: ${e.toString()}',
      );
    }
  }
}
