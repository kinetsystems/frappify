import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:frappify/apps/apps.dart';

class AppsPage extends StatelessWidget {
  const AppsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppsBloc(
        frappe: context.read<FrappeClient>(),
      )..add(LoadAppsEvent()),
      child: const AppsView(),
    );
  }
}
