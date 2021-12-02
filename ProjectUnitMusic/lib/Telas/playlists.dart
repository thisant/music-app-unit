import 'package:MusicAppUnit/Dispositivos/montagem.dart';
import 'package:MusicAppUnit/Dispositivos/cores_degrade.dart';
import 'package:MusicAppUnit/Dispositivos/miniplayer.dart';
import 'package:MusicAppUnit/Dispositivos/caixa_dialogo.dart';
import 'package:MusicAppUnit/Telas/favoritos.dart';
import 'package:MusicAppUnit/Dispositivos/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';


class PlaylistScreen extends StatefulWidget {
  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  Box settingsBox = Hive.box('settings');
  List playlistNames = [];
  Map playlistDetails = {};
  @override
  Widget build(BuildContext context) {
    playlistNames = settingsBox.get('playlistNames')?.toList() as List? ??
        ['Favoritas'];
    if (!playlistNames.contains('Favoritas')) {
      playlistNames.insert(0, 'Favoritas');
      settingsBox.put('playlistNames', playlistNames);
    }
    playlistDetails =
    settingsBox.get('playlistDetails', defaultValue: {}) as Map;

    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.playlists,
                ),
                centerTitle: true,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.secondary,
                elevation: 0,
              ),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 5),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.createPlaylist),
                      leading: Card(
                        elevation: 0,
                        color: Colors.transparent,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Icon(
                              Icons.queue_outlined,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        await TextInputDialog().showTextInputDialog(
                            context: context,
                            title:
                            AppLocalizations.of(context)!.createNewPlaylist,
                            initialText: '',
                            keyboardType: TextInputType.name,
                            onSubmitted: (String value) {
                              if (value.trim() == '') {
                                value = 'Playlist ${playlistNames.length}';
                              }
                              while (playlistNames.contains(value)) {
                                // ignore: use_string_buffers
                                value = '$value (1)';
                              }
                              playlistNames.add(value);
                              settingsBox.put('playlistNames', playlistNames);
                              Navigator.pop(context);
                            });
                        setState(() {});
                      },
                    ),
                    if (playlistNames.isEmpty)
                      const SizedBox()
                    else
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: playlistNames.length,
                          itemBuilder: (context, index) {
                            final String name = playlistNames[index].toString();
                            final String showName = playlistDetails
                                .containsKey(name)
                                ? playlistDetails[name]['name']?.toString() ??
                                name
                                : name;
                            return ListTile(
                              leading: (playlistDetails[name] == null ||
                                  playlistDetails[name]['imagesList'] ==
                                      null ||
                                  (playlistDetails[name]['imagesList']
                                  as List)
                                      .isEmpty)
                                  ? Card(
                                elevation: 5,
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(7.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child:
                                  name.toString() == 'Favoritas'
                                      ? const Image(
                                      image: AssetImage(
                                          'assets/cover.jpg'))
                                      : const Image(
                                      image: AssetImage(
                                          'assets/album.png')),
                                ),
                              )
                                  : Collage(
                                  imageList: playlistDetails[name]
                                  ['imagesList'] as List,
                                  placeholderImage: 'assets/cover.jpg'),
                              title: Text(
                                showName,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: playlistDetails[name] == null ||
                                  playlistDetails[name]['count'] == null ||
                                  playlistDetails[name]['count'] == 0
                                  ? null
                                  : Text(
                                  '${playlistDetails[name]['count']} Música(s)'),


                              trailing: PopupMenuButton(

                                icon: Icon(name != 'Favoritas' ? Icons.more_vert_rounded: null),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(15.0))),
                                onSelected: (int? value) async {
                                  if (value == 0) {
                                    ShowSnackBar().showSnackBar(
                                      context,
                                      '${AppLocalizations.of(context)!.deleted} $showName',
                                    );
                                    playlistDetails.remove(name);
                                    await settingsBox.put(
                                        'playlistDetails', playlistDetails);
                                    await Hive.openBox(name);
                                    await Hive.box(name).deleteFromDisk();
                                    await playlistNames.removeAt(index);
                                    await settingsBox.put(
                                        'playlistNames', playlistNames);
                                    setState(() {});
                                  }
                                  if (value == 3) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        final _controller =
                                        TextEditingController(
                                            text: showName);
                                        return AlertDialog(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(
                                                        context)!
                                                        .rename,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary),
                                                  ),
                                                ],
                                              ),
                                              TextField(
                                                  autofocus: true,
                                                  textAlignVertical:
                                                  TextAlignVertical.bottom,
                                                  controller: _controller,
                                                  onSubmitted: (value) async {
                                                    Navigator.pop(context);
                                                    playlistDetails[name] ==
                                                        null
                                                        ? playlistDetails
                                                        .addAll({
                                                      name: {
                                                        'name':
                                                        value.trim()
                                                      }
                                                    })
                                                        : playlistDetails[name]
                                                        .addAll({
                                                      'name': value.trim()
                                                    });

                                                    await settingsBox.put(
                                                        'playlistDetails',
                                                        playlistDetails);
                                                    setState(() {});
                                                  }),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                primary: Theme.of(context)
                                                    .iconTheme
                                                    .color,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .cancel),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                primary: Colors.white,
                                                backgroundColor:
                                                Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                playlistDetails[name] == null
                                                    ? playlistDetails.addAll({
                                                  name: {
                                                    'name': _controller
                                                        .text
                                                        .trim()
                                                  }
                                                })
                                                    : playlistDetails[name]
                                                    .addAll({
                                                  'name': _controller.text
                                                      .trim()
                                                });

                                                await settingsBox.put(
                                                    'playlistDetails',
                                                    playlistDetails);
                                                setState(() {});
                                              },
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .ok,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary ==
                                                        Colors.white
                                                        ? Colors.black
                                                        : null),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (name != 'Favoritas')
                                    PopupMenuItem(
                                      value: 3,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit_rounded),
                                          const SizedBox(width: 10.0),
                                          Text(AppLocalizations.of(context)!
                                              .rename),
                                        ],
                                      ),
                                    ),
                                  if (name != 'Favoritas')
                                    PopupMenuItem(
                                      value: 0,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.delete_rounded),
                                          const SizedBox(width: 10.0),
                                          Text(AppLocalizations.of(context)!
                                              .delete),
                                        ],
                                      ),
                                    ),

                                ],

                              ),
                              onTap: () async {
                                await Hive.openBox(name);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LikedSongs(
                                        playlistName: name,
                                        showName:
                                        playlistDetails.containsKey(name)
                                            ? playlistDetails[name]['name']
                                            ?.toString() ??
                                            name
                                            : name),
                                  ),
                                );
                              },
                            );
                          })
                  ],
                ),
              ),
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}
