import 'dart:ui';

import 'package:MusicAppUnit/API/api.dart';
import 'package:MusicAppUnit/Dispositivos/tela_vazia.dart';
import 'package:MusicAppUnit/Dispositivos/cores_degrade.dart';
import 'package:MusicAppUnit/Dispositivos/miniplayer.dart';
import 'package:MusicAppUnit/Telas/lista.dart';
import 'package:MusicAppUnit/Telas/bandas.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AlbumSearchPage extends StatefulWidget {
  final String query;
  final String type;

  const AlbumSearchPage({
    Key? key,
    required this.query,
    required this.type,
  }) : super(key: key);

  @override
  _AlbumSearchPageState createState() => _AlbumSearchPageState();
}

class _AlbumSearchPageState extends State<AlbumSearchPage> {
  bool status = false;
  List<Map> searchedList = [];
  bool fetched = false;

  @override
  Widget build(BuildContext context) {
    if (!status) {
      status = true;
      switch (widget.type) {
        case 'Playlists':
          SaavnAPI().fetchAlbums(widget.query, 'playlist').then((value) {
            setState(() {
              searchedList = value;
              fetched = true;
            });
          });
          break;
        case 'Albums':
          SaavnAPI().fetchAlbums(widget.query, 'album').then((value) {
            setState(() {
              searchedList = value;
              fetched = true;
            });
          });
          break;
        case 'Artists':
          SaavnAPI().fetchAlbums(widget.query, 'artist').then((value) {
            setState(() {
              searchedList = value;
              fetched = true;
            });
          });
          break;
        default:
          break;
      }
    }
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: !fetched
                  ? SizedBox(
                      child: Center(
                        child: SizedBox(
                            height: MediaQuery.of(context).size.width / 7,
                            width: MediaQuery.of(context).size.width / 7,
                            child: const CircularProgressIndicator()),
                      ),
                    )
                  : searchedList.isEmpty
                      ? EmptyScreen().emptyScreen(
                          context,
                          0,
                          ':( ',
                          100,
                          AppLocalizations.of(context)!.sorry,
                          60,
                          AppLocalizations.of(context)!.resultsNotFound,
                          20)
                      : CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverAppBar(
                              // backgroundColor: Colors.transparent,
                              elevation: 0,
                              stretch: true,
                              pinned: true,
                              // floating: true,
                              expandedHeight:
                                  MediaQuery.of(context).size.height * 0.4,
                              flexibleSpace: FlexibleSpaceBar(
                                title: Text(
                                  widget.type,
                                  textAlign: TextAlign.center,
                                ),
                                centerTitle: true,
                                background: ShaderMask(
                                    shaderCallback: (rect) {
                                      return const LinearGradient(
                                        begin: Alignment.center,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black,
                                          Colors.transparent
                                        ],
                                      ).createShader(Rect.fromLTRB(
                                          0, 0, rect.width, rect.height));
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: Image(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                            widget.type == 'Artists'
                                                ? 'assets/artist.png'
                                                : 'assets/album.png'))),
                              ),
                            ),
                            SliverList(
                                delegate:
                                    SliverChildListDelegate(searchedList.map(
                              (Map entry) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 7, 7, 5),
                                  child: ListTile(
                                    contentPadding:
                                        const EdgeInsets.only(left: 15.0),
                                    title: Text(
                                      '${entry["title"]}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      '${entry["subtitle"]}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    leading: Card(
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              widget.type == 'Artists'
                                                  ? 50.0
                                                  : 7.0)),
                                      clipBehavior: Clip.antiAlias,
                                      child: CachedNetworkImage(
                                        errorWidget: (context, _, __) => Image(
                                          image: AssetImage(
                                              widget.type == 'Artists'
                                                  ? 'assets/artist.png'
                                                  : 'assets/album.png'),
                                        ),
                                        imageUrl:
                                            '${entry["image"].replaceAll('http:', 'https:')}',
                                        placeholder: (context, url) => Image(
                                          image: AssetImage(
                                              widget.type == 'Artists'
                                                  ? 'assets/artist.png'
                                                  : 'assets/album.png'),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          opaque: false,
                                          pageBuilder: (_, __, ___) => widget
                                                      .type ==
                                                  'Artists'
                                              ? ArtistSearchPage(
                                                  artistName:
                                                      entry['title'].toString(),
                                                  artistToken:
                                                      entry['artistToken']
                                                          .toString(),
                                                  artistImage:
                                                      entry['image'].toString())
                                              : SongsListPage(listItem: entry),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ).toList())),
                          ],
                        ),
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}
