part of 'onboarding_bloc.dart';

class OnboardingState extends Equatable {
  const OnboardingState({
    required this.onboardingCompleted,
    required this.isLoading,
  });

  factory OnboardingState.initial() => const OnboardingState(
    onboardingCompleted: false,
    isLoading: false,
  );

  final bool onboardingCompleted;
  final bool isLoading;

  OnboardingState copyWith({
    bool? onboardingCompleted,
    bool? isLoading,
  }) {
    return OnboardingState(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    onboardingCompleted,
    isLoading,
  ];
}
