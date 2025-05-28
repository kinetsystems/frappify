import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:frappify/app_config/bloc/app_config_bloc.dart';
import 'package:frappify/app_config/view/app_config_view.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfigPage extends StatelessWidget {
  const AppConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppConfigBloc(
        sharedPreferences: context.read<SharedPreferences>(),
        secureStorage: context.read<SecureStorage>(),
        frappe: context.read<FrappeClient>(),
      ),
      child: const AppConfigView(),
    );
  }
}
