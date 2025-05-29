part of 'app_start_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

class AppStartState extends Equatable {
  const AppStartState({
    required this.isLoggedIn,
    required this.isCookieTimedOut,
    this.message,
    this.time,
  });

  factory AppStartState.initial() => const AppStartState(
        isLoggedIn: false,
        isCookieTimedOut: false,
        message: '',
        time: 0,
      );

  final bool isLoggedIn;
  final bool isCookieTimedOut;
  final String? message;
  final int? time;

  AppStartState copyWith({
    bool? isLoggedIn,
    bool? isCookieTimedOut,
    String? message,
    int? time,
  }) {
    return AppStartState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isCookieTimedOut:
          isCookieTimedOut ?? this.isCookieTimedOut,
      message: message ?? this.message,
      time: time ?? this.time,
    );
  }

  @override
  List<Object?> get props => [
        isLoggedIn,
        isCookieTimedOut,
        message,
        time,
      ];
}
