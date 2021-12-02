import 'dart:io';

import 'package:MusicAppUnit/Telas/youtube.dart';
import 'package:audio_service/audio_service.dart';
import 'package:MusicAppUnit/Configuradores/rota.dart';
import 'package:MusicAppUnit/Telas/playlists.dart';
import 'package:MusicAppUnit/Telas/Login.dart';
import 'package:MusicAppUnit/Telas/audioplayer.dart';
import 'package:MusicAppUnit/Serviços/audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

// TODO: use getit to register handler in future
late AudioPlayerHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;

  await Hive.initFlutter();
  await openHiveBox('settings');
  await openHiveBox('downloads');
  await openHiveBox('cache', limit: true);
  if (Platform.isAndroid) {
    setOptimalDisplayMode();
  }
  await startService();
  runApp(MyApp());
}

Future<void> setOptimalDisplayMode() async {
  final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  final DisplayMode active = await FlutterDisplayMode.active;

  final List<DisplayMode> sameResolution = supported
      .where((DisplayMode m) =>
          m.width == active.width && m.height == active.height)
      .toList()
    ..sort((DisplayMode a, DisplayMode b) =>
        b.refreshRate.compareTo(a.refreshRate));

  final DisplayMode mostOptimalMode =
      sameResolution.isNotEmpty ? sameResolution.first : active;

  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
}

Future<void> startService() async {
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.shadow.musicbox.channel.audio',
      androidNotificationChannelName: 'MusicBox',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'drawable/ic_stat_music_note',
      androidShowNotificationBadge: true,
      notificationColor: Colors.grey[900],
    ),
  );
}

Future<void> openHiveBox(String boxName, {bool limit = false}) async {
  if (limit) {
    final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String dirPath = dir.path;
      final File dbFile = File('$dirPath/$boxName.hive');
      final File lockFile = File('$dirPath/$boxName.lock');
      await dbFile.delete();
      await lockFile.delete();
      await Hive.openBox(boxName);
      throw 'Failed to open $boxName Box\nError: $error';
    });
    // clear box if it grows large
    if (box.length > 500) {
      box.clear();
    }
    await Hive.openBox(boxName);
  } else {
    await Hive.openBox(boxName).onError((error, stackTrace) async {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String dirPath = dir.path;
      final File dbFile = File('$dirPath/$boxName.hive');
      final File lockFile = File('$dirPath/$boxName.lock');
      await dbFile.delete();
      await lockFile.delete();
      await Hive.openBox(boxName);
      throw 'Failed to open $boxName Box\nError: $error';
    });
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  Widget initialFuntion() {
    return Hive.box('settings').get('auth') != null ? YouTube() : AuthScreen();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      title: 'MusicBox',
      restorationScopeId: 'musicbox',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      routes: {
        '/': (context) => initialFuntion(),
        '/pref': (context) => YouTube(),
        '/playlists': (context) => PlaylistScreen(),
      },
      onGenerateRoute: (RouteSettings settings) {
        return HandleRoute().handleRoute(settings.name);
      },
    );
  }
}
