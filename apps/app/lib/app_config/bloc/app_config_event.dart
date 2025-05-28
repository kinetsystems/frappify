part of 'app_config_bloc.dart';

abstract class AppConfigEvent extends Equatable {
  const AppConfigEvent();
}

class SubmitHostAddressEvent extends AppConfigEvent {
  const SubmitHostAddressEvent({required this.hostAddress});

  final String hostAddress;

  @override
  List<Object> get props => [hostAddress];
}
