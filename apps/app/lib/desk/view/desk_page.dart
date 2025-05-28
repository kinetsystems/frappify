import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:frappify/desk/desk.dart';
import 'package:secure_storage/secure_storage.dart';

class DeskPage extends StatelessWidget {
  const DeskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DeskBloc(
              frappe: context.read<FrappeClient>(),
              secureStorage: context.read<SecureStorage>(),
            )
            ..add(LoadUserDataEvent())
            ..add(LoadWorkspacesEvent()),
      child: const DeskView(),
    );
  }
}
