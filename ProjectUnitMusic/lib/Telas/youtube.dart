import 'dart:async';

import 'package:MusicAppUnit/Dispositivos/cores_degrade.dart';
import 'package:MusicAppUnit/Telas/youtube_playlist.dart';
import 'package:MusicAppUnit/Telas/pesquisa.dart';
import 'package:MusicAppUnit/Serviços/youtube_api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:MusicAppUnit/Dispositivos/miniplayer.dart';

bool status = false;
List searchedList = Hive.box('cache').get('ytHome', defaultValue: []) as List;
List headList = Hive.box('cache').get('ytHomeHead', defaultValue: []) as List;

class YouTube extends StatefulWidget {
  const YouTube({Key? key}) : super(key: key);

  @override
  _YouTubeState createState() => _YouTubeState();
}

class _YouTubeState extends State<YouTube>
    with AutomaticKeepAliveClientMixin<YouTube> {
  List ytSearch =
      Hive.box('settings').get('ytSearch', defaultValue: []) as List;
  bool showHistory =
      Hive.box('settings').get('showHistory', defaultValue: true) as bool;
  final FloatingSearchBarController _controller = FloatingSearchBarController();
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (!status) {
      YouTubeServices().getMusicHome().then((value) {
        status = true;
        if (value.isNotEmpty) {
          setState(() {
            searchedList = value['body'] ?? [];
            headList = value['head'] ?? [];

            Hive.box('cache').put('ytHome', value['body']);
            Hive.box('cache').put('ytHomeHead', value['head']);
          });
        } else {
          status = false;
        }
      });
    }
    if (headList.isNotEmpty) {
      Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (_currentPage < headList.length) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      });
    }
    super.initState();
  }

  String capitalize(String msg) {
    return '${msg[0].toUpperCase()}${msg.substring(1)}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext cntxt) {
    super.build(context);
    final double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height;

    return GradientContainer(

      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Scaffold(
                body: FloatingSearchBar(
                  borderRadius: BorderRadius.circular(8.0),
                  controller: _controller,
                  automaticallyImplyBackButton: false,
                  automaticallyImplyDrawerHamburger: false,
                  elevation: 8.0,
                  insets: EdgeInsets.zero,
                  leadingActions: [
                    FloatingSearchBarAction.icon(
                      onTap: () => _controller.close(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      showIfOpened: true,
                      showIfClosed: false,
                    ),
                    FloatingSearchBarAction.icon(
                      size: 20.0,
                      icon: Transform.rotate(
                        angle: 22 / 7 * 2,
                        child: const Icon(
                          Icons.music_note_rounded,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/playlists');
                      },
                    ),
                  ],
                  hint: AppLocalizations.of(context)!.searchYt,
                  height: 52.0,
                  margins: const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 15.0),
                  scrollPadding: const EdgeInsets.only(bottom: 50),
                  backdropColor: Colors.black12,
                  transitionCurve: Curves.easeInOut,
                  physics: const BouncingScrollPhysics(),
                  openAxisAlignment: 0.0,
                  debounceDelay: const Duration(milliseconds: 500),
                  onSubmitted: (_query) {
                    _controller.close();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (_, __, ___) => YouTubeSearchPage(
                          query: _query,
                        ),
                      ),
                    );
                    setState(() {
                      if (ytSearch.contains(_query)) ytSearch.remove(_query);
                      ytSearch.insert(0, _query);
                      if (ytSearch.length > 10)
                        ytSearch = ytSearch.sublist(0, 10);
                      Hive.box('settings').put('ytSearch', ytSearch);
                    });
                  },
                  transition: CircularFloatingSearchBarTransition(),
                  actions: [
                    FloatingSearchBarAction(
                      child: CircularButton(
                        icon: const Icon(Icons.youtube_searched_for_rounded),
                        onPressed: () {},
                      ),
                    ),
                    FloatingSearchBarAction(
                      showIfOpened: true,
                      showIfClosed: false,
                      child: CircularButton(
                        icon: const Icon(
                          CupertinoIcons.clear,
                          size: 20.0,
                        ),
                        onPressed: () {
                          _controller.clear();
                        },
                      ),
                    ),
                  ],
                  builder: (context, transition) {
                    if (!showHistory) {
                      return const SizedBox();
                    } else {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                      );
                    }
                  },
                  body: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(10, 80, 10, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                AppLocalizations.of(context)!.homeGreet,
                                style: TextStyle(
                                    letterSpacing: 2,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 25,
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
                                        fontSize: 25,
                                        fontWeight: FontWeight.w500),
                                  );
                                }),
                          ],
                        ),
                        if (headList.isNotEmpty)
                          if (searchedList.isEmpty)
                            SizedBox(
                              child: Center(
                                child: SizedBox(
                                    height: boxSize / 7,
                                    width: boxSize / 7,
                                    child: Image(
                                        image:
                                            AssetImage('assets/musicbox.png'),
                                        height: 300,
                                        width: 300)),
                              ),
                            )
                          else
                            ListView.builder(
                                itemCount: searchedList.length,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(bottom: 10),
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 0, 5),
                                            child: Text(
                                              '${searchedList[index]["title"]}',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: boxSize / 2 + 10,
                                        width: double.infinity,
                                        child: ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          itemCount: (searchedList[index]
                                                  ['playlists'] as List)
                                              .length,
                                          itemBuilder: (context, idx) {
                                            final item = searchedList[index]
                                                ['playlists'][idx];
                                            return GestureDetector(
                                              onTap: () {
                                                item['type'] == 'video'
                                                    ? Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          opaque: false,
                                                          pageBuilder: (_, __,
                                                                  ___) =>
                                                              YouTubeSearchPage(
                                                            query: item['title']
                                                                .toString(),
                                                          ),
                                                        ),
                                                      )
                                                    : Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          opaque: false,
                                                          pageBuilder: (_, __,
                                                                  ___) =>
                                                              YouTubePlaylist(
                                                            playlistId: item[
                                                                    'playlistId']
                                                                .toString(),
                                                            playlistImage: item[
                                                                    'imageStandard']
                                                                .toString(),
                                                            playlistName:
                                                                item['title']
                                                                    .toString(),
                                                          ),
                                                        ),
                                                      );
                                              },
                                              child: SizedBox(
                                                width:
                                                    item['type'] != 'playlist'
                                                        ? boxSize - 100
                                                        : boxSize / 2 - 10,
                                                child: Column(
                                                  children: [
                                                    Card(
                                                      elevation: 5,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        errorWidget:
                                                            (context, _, __) =>
                                                                Image(
                                                          image: item['type'] !=
                                                                  'playlist'
                                                              ? const AssetImage(
                                                                  'assets/ytCover.png')
                                                              : const AssetImage(
                                                                  'assets/cover.jpg'),
                                                        ),
                                                        imageUrl: item['image']
                                                            .toString(),
                                                        placeholder:
                                                            (context, url) =>
                                                                Image(
                                                          image: item['type'] !=
                                                                  'playlist'
                                                              ? const AssetImage(
                                                                  'assets/ytCover.png')
                                                              : const AssetImage(
                                                                  'assets/cover.jpg'),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${item["title"]}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      softWrap: false,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      //MiniPlayer()
                                    ],
                                  );
                                }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            MiniPlayer(),
          ],
        ),
      ),
    );

    //MiniPlayer();
  }
}
