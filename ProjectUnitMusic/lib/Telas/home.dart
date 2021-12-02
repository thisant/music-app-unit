import 'package:MusicAppUnit/Dispositivos/physics.dart';
import 'package:MusicAppUnit/Dispositivos/cores_degrade.dart';
import 'package:MusicAppUnit/Dispositivos/miniplayer.dart';
import 'package:MusicAppUnit/Dispositivos/snackbar.dart';
import 'package:MusicAppUnit/Configuradores/supabase.dart';
import 'package:MusicAppUnit/Telas/youtube.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  bool checked = false;
  String? appVersion;
  String name =
      Hive.box('settings').get('name', defaultValue: 'Guest') as String;
  bool checkUpdate =
      Hive.box('settings').get('checkUpdate', defaultValue: false) as bool;
  DateTime? backButtonPressTime;

  String capitalize(String msg) {
    return '${msg[0].toUpperCase()}${msg.substring(1)}';
  }

  void callback() {
    setState(() {});
  }

  void _onItemTapped(int index) {
    _selectedIndex.value = index;
    pageController.jumpToPage(
      index,
    );
  }

  bool compareVersion(String latestVersion, String currentVersion) {
    bool update = false;
    final List latestList = latestVersion.split('.');
    final List currentList = currentVersion.split('.');

    for (int i = 0; i < latestList.length; i++) {
      try {
        if (int.parse(latestList[i] as String) >
            int.parse(currentList[i] as String)) {
          update = true;
          break;
        }
      } catch (e) {
        break;
      }
    }
    return update;
  }

  void updateUserDetails(String key, dynamic value) {
    final userId = Hive.box('settings').get('userId') as String?;
    SupaBase().updateUserDetails(userId, key, value);
  }

  Future<bool> handleWillPop(BuildContext context) async {
    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            now.difference(backButtonPressTime!) > const Duration(seconds: 3);

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = now;
      ShowSnackBar().showSnackBar(
        context,
        AppLocalizations.of(context)!.exitConfirm,
        duration: const Duration(seconds: 2),
        noAction: true,
      );
      return false;
    }
    return true;
  }

  Widget checkVersion() {
    if (!checked && Theme.of(context).platform == TargetPlatform.android) {
      checked = true;
      final SupaBase db = SupaBase();
      final DateTime now = DateTime.now();
      final List lastLogin = now
          .toUtc()
          .add(const Duration(hours: 5, minutes: 30))
          .toString()
          .split('.')
        ..removeLast()
        ..join('.');
      updateUserDetails('lastLogin', '${lastLogin[0]} IST');
      final String offset =
          now.timeZoneOffset.toString().replaceAll('.000000', '');

      updateUserDetails(
          'timeZone', 'Zone: ${now.timeZoneName}, Offset: $offset');

      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        appVersion = packageInfo.version;
        updateUserDetails('version', packageInfo.version);

        if (checkUpdate) {
          db.getUpdate().then((Map value) {
            if (compareVersion(value['LatestVersion'] as String, appVersion!)) {
              ShowSnackBar().showSnackBar(
                context,
                AppLocalizations.of(context)!.updateAvailable,
                duration: const Duration(seconds: 15),
                action: SnackBarAction(
                  textColor: Theme.of(context).colorScheme.secondary,
                  label: AppLocalizations.of(context)!.update,
                  onPressed: () {
                    Navigator.pop(context);
                    launch(value['LatestUrl'] as String);
                  },
                ),
              );
            }
          });
        }
      });
      if (Hive.box('settings').get('proxyIp') == null) {
        Hive.box('settings').put('proxyIp', '103.47.67.134');
      }
      if (Hive.box('settings').get('proxyPort') == null) {
        Hive.box('settings').put('proxyPort', 8080);
      }
      return const SizedBox();
    } else {
      return const SizedBox();
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        drawer: Drawer(
          child: GradientContainer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomScrollView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                      elevation: 0,
                      stretch: true,
                      expandedHeight: MediaQuery.of(context).size.height * 0.2,
                      flexibleSpace: FlexibleSpaceBar(
                        title: RichText(
                          text: TextSpan(
                            text: AppLocalizations.of(context)!.appTitle,
                            style: const TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w500,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    appVersion == null ? '' : '\nv$appVersion',
                                style: const TextStyle(
                                  fontSize: 7.0,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.end,
                        ),
                        titlePadding: const EdgeInsets.only(bottom: 40.0),
                        centerTitle: true,
                        background: ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.black.withOpacity(0.1),
                              ],
                            ).createShader(
                                Rect.fromLTRB(0, 0, rect.width, rect.height));
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image(
                              alignment: Alignment.topCenter,
                              image: AssetImage(Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? 'assets/header-dark.jpg'
                                  : 'assets/header.jpg')),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          ListTile(
                            title: Text(
                              AppLocalizations.of(context)!.home,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            leading: Icon(
                              Icons.home_rounded,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            selected: true,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(
                              AppLocalizations.of(context)!.youTube,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            leading: Icon(
                              MdiIcons.youtube,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            selected: true,
                            onTap: () {
                              //Navigator.pop(context);
                              Navigator.pushNamed(context, '/Youtube');
                            },
                          ),
                          ListTile(
                            title: Text(
                              AppLocalizations.of(context)!.library,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            leading: Icon(
                              Icons.my_library_music_rounded,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            selected: true,
                            onTap: () {
                              Navigator.pushNamed(context, '/Library');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 30, 5, 20),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.madeBy,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: WillPopScope(
          onWillPop: () => handleWillPop(context),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    physics: const CustomPhysics(),
                    onPageChanged: (indx) {
                      _selectedIndex.value = indx;
                    },
                    controller: pageController,
                    children: [
                      Stack(
                        children: [
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                AppLocalizations.of(context)!.homeGreet,
                                style: TextStyle(
                                    letterSpacing: 2,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            ValueListenableBuilder(
                                valueListenable:
                                    Hive.box('settings').listenable(),
                                builder:
                                    (BuildContext context, Box box, widget) {
                                  return Text(
                                    (box.get('name') == null ||
                                            box.get('name') == '')
                                        ? 'Guest'
                                        : capitalize(box
                                            .get('name')
                                            .split(' ')[0]
                                            .toString()),
                                    style: const TextStyle(
                                        letterSpacing: 2,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w500),
                                  );
                                }),
                          ]),
                          checkVersion(),
                        ],
                      ),
                      const YouTube(),
                    ],
                  ),
                ),
                MiniPlayer()
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: ValueListenableBuilder(
              valueListenable: _selectedIndex,
              builder: (BuildContext context, int indexValue, Widget? child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: 60,
                  child: SalomonBottomBar(
                    currentIndex: indexValue,
                    onTap: (index) {
                      _onItemTapped(index);
                    },
                    items: [
                      /// Home
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.home_rounded),
                        title: Text(AppLocalizations.of(context)!.home),
                        selectedColor: Theme.of(context).colorScheme.secondary,
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(MdiIcons.youtube),
                        title: Text(AppLocalizations.of(context)!.youTube),
                        selectedColor: Theme.of(context).colorScheme.secondary,
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.my_library_music_rounded),
                        title: Text(AppLocalizations.of(context)!.library),
                        selectedColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}
