part of 'apps_bloc.dart';

abstract class AppsEvent extends Equatable {
  const AppsEvent();

  @override
  List<Object> get props => [];
}

class LoadAppsEvent extends AppsEvent {}
