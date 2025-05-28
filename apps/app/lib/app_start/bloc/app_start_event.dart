part of 'app_start_bloc.dart';

abstract class AppStartEvent extends Equatable {
  const AppStartEvent();

  @override
  List<Object> get props => [];
}

class StartCookieCheckUpEvent extends AppStartEvent {
  const StartCookieCheckUpEvent();


  @override
  List<Object> get props => [];
}


class StopCookieCheckUpEvent extends AppStartEvent {
  const StopCookieCheckUpEvent();

  @override
  List<Object> get props => [];
}

class ExpiredLogoutEvent extends AppStartEvent {
  const ExpiredLogoutEvent(this.navigatorKey );

  final GlobalKey<NavigatorState> navigatorKey ;

  @override
  List<Object> get props => [];
}