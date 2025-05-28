import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_config_event.dart';
part 'app_config_state.dart';

class AppConfigBloc extends Bloc<AppConfigEvent, AppConfigState> {

  AppConfigBloc({
    required this.sharedPreferences,
    required this.frappe,
    required this.secureStorage,
  }) : super(AppConfigState.initial()) {
    on<SubmitHostAddressEvent>(_onSubmitHostAddress);
  }
  final SharedPreferences sharedPreferences;
  final FrappeClient frappe;

  final SecureStorage secureStorage;

  Future<void> _onSubmitHostAddress(
    SubmitHostAddressEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    await secureStorage.write(key: 'host_address', value: event.hostAddress);
    frappe.baseUrl = event.hostAddress;
  }
}
