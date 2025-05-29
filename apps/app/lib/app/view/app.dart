import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:frappify/app_start/app_start.dart';
import 'package:frappify/l10n/l10n.dart';
import 'package:frappify/services/app_global_context.dart';
import 'package:frappify/services/toast_service.dart';
import 'package:frappify/settings/settings.dart';
import 'package:frappify/splash/splash.dart';
import 'package:frappify/utils/utils.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:toastification/toastification.dart';

class App extends StatelessWidget {
  App({
    required FrappeClient frappe,
    required PersistentStorage persistentStorage,
    required SecureStorage secureStorage,
    super.key,
  }) : _frappe = frappe,
       _persistentStorage = persistentStorage,
       _secureStorage = secureStorage;

  final FrappeClient _frappe;
  final PersistentStorage _persistentStorage;
  final SecureStorage _secureStorage;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _frappe),
        RepositoryProvider.value(value: _persistentStorage),
        RepositoryProvider.value(value: _secureStorage),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (context) =>
                SettingsBloc(frappe: _frappe, secureStorage: _secureStorage),
          ),
          BlocProvider(
            lazy: false,
            create: (context) =>
                AppStartBloc(frappe: _frappe, secureStorage: _secureStorage),
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return ShadApp(
              navigatorKey: navigatorKey,
              builder: (context, child) {
                AppGlobalContext.setContext(context);
                return ToastificationWrapper(
                  child: BlocListener<AppStartBloc, AppStartState>(
                    listener: (context, state) {
                      if (state.isCookieTimedOut && state.isLoggedIn) {
                        context.read<AppStartBloc>().add(
                          ExpiredLogoutEvent(navigatorKey),
                        );
                      }
                      if (state.message != null && state.isLoggedIn) {
                        ToastService.showWarningToast(message: state.message!);
                      }
                    },
                    child: ResponsiveBreakpoints.builder(
                      child: child!,
                      breakpoints: const [
                        Breakpoint(start: 0, end: 450, name: MOBILE),
                        Breakpoint(start: 451, end: 800, name: TABLET),
                        Breakpoint(start: 801, end: 1920, name: DESKTOP),
                        Breakpoint(
                          start: 1921,
                          end: double.infinity,
                          name: '4K',
                        ),
                      ],
                    ),
                  ),
                );
              },
              title: 'Frappify',
              scrollBehavior: MouseScrollBehavior(),
              theme: const AppTheme().themeData,
              darkTheme: const AppDarkTheme().themeData,
              themeMode: state.themeMode,
              locale: state.locale,
              localizationsDelegates: const [
                ...AppLocalizations.localizationsDelegates,
              ],
              supportedLocales: const [...AppLocalizations.supportedLocales],
              home: const SplashPage(),
            );
          },
        ),
      ),
    );
  }
}
