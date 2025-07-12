part of 'app_config_bloc.dart';

class AppConfigState extends Equatable {
  final bool isLoading;

  AppConfigState({required this.isLoading});

  factory AppConfigState.initial() => AppConfigState(isLoading: false);

  AppConfigState copyWith({bool? isLoading}) {
    return AppConfigState(
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [isLoading];
}