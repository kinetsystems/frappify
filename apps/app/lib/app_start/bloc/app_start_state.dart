part of 'app_start_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

class AppStartState extends Equatable {
  const AppStartState({
    this.isCookieTimedOut = false,
    this.message,
    this.time,
  });

  factory AppStartState.initial() => const AppStartState(
        message: '',
        time: 0,
      );

  final bool isCookieTimedOut;
  final String? message;
  final int? time;

  AppStartState copyWith({
    bool? isCookieTimedOut,
    String? message,
    int? time,
  }) {
    return AppStartState(
      isCookieTimedOut:
          isCookieTimedOut ?? this.isCookieTimedOut,
      message: message ?? this.message,
      time: time ?? this.time,
    );
  }

  @override
  List<Object?> get props => [
        isCookieTimedOut,
        message,
        time,
      ];
}
