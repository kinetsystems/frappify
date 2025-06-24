part of 'apps_bloc.dart';

class AppsState extends Equatable {
  const AppsState({
    this.apps,
  });

  factory AppsState.initial() => const AppsState();

  final List<Message>? apps;

  AppsState copyWith({
    List<Message>? apps,
  }) => AppsState(
    apps: apps ?? this.apps,
  );

  factory AppsState.fromMap(Map<String, dynamic> json) => AppsState(
    apps: json['apps'] as List<Message>?,
  );

  factory AppsState.fromJson(String json) =>
      AppsState.fromMap(jsonDecode(json) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'apps': apps,
  };

  String toJson() => jsonEncode(toMap());

  @override
  List<Object> get props => [
    apps ?? [],
  ];
}
