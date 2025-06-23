import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app_logger/app_logger.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:frappify/main/bootstrap/app_bloc_observer.dart';
import 'package:frappify/utils/platform.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef AppBuilder =
    Future<Widget> Function(
      FrappeClient frappe,
      PersistentStorage persistentStorage,
      SecureStorage secureStorage,
    );

Future<void> bootstrap(AppBuilder builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  AppLogger.initialize(verbose: true);

  await AppLogger.runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (kIsWeb) {
      await Hive.initFlutter();
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: HydratedStorageDirectory.web,
      );
    } else {
      var customPath = '';
      if (Platform.isLinux) {
        final homeDir = Platform.environment['HOME'];
        if (homeDir != null) {
          customPath = '$homeDir/.frappify/databases';
        }
      } else if (Platform.isWindows) {
        final homeDir = Platform.environment['USERPROFILE'];
        if (homeDir != null) {
          customPath = '$homeDir\\frappify\\databases';
        }
      } else if (Platform.isMacOS || Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        customPath = '${directory.path}/.frappify/databases';
      } else if (Platform.isAndroid) {
        final directory = await getApplicationDocumentsDirectory();
        // final directory = await getExternalStorageDirectory();
        // final directory = Platform.environment['EXTERNAL_STORAGE'];
        customPath = '${directory.path}/.frappify/databases';
        // customPath = '$directory/.frappify/databases';
      }

      final directory = Directory(customPath);
      await directory.create(recursive: true);

      if (Platform.isWindows) {
        await Process.run('attrib', ['+h', directory.path]);
      }

      Hive.init(customPath);
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: HydratedStorageDirectory(directory.path),
      );
    }

    Bloc.observer = const AppBlocObserver();

    final sharedPreferences = await SharedPreferences.getInstance();

    final persistentStorage = PersistentStorage(
      sharedPreferences: sharedPreferences,
    );
    const secureStorage = SecureStorage();

    final host = await secureStorage.read(key: 'host_address');

    final frappe = FrappeClient(
      baseUrl: host != null && host != '' ? host : 'https://example.com',
    );

    final appWidget = await builder(frappe, persistentStorage, secureStorage);

    runApp(
      DevicePreview(
        enabled: !kReleaseMode && !kIsAndroid,
        builder: (context) => appWidget,
      ),
    );
  });
}
