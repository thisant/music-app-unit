import 'package:audio_service/audio_service.dart';
import 'package:MusicAppUnit/Dispositivos/snackbar.dart';
import 'package:MusicAppUnit/Configuradores/playlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LikeButton extends StatefulWidget {
  final MediaItem mediaItem;
  final double? size;
  const LikeButton({Key? key, required this.mediaItem, this.size})
      : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool liked = false;

  @override
  Widget build(BuildContext context) {
    try {
      liked = checkPlaylist('Favoritas', widget.mediaItem.id);
    } catch (e) {
    }
    return IconButton(
        icon: Icon(
          liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: liked ? Colors.blueAccent : Theme.of(context).iconTheme.color,
        ),
        iconSize: widget.size ?? 30.0,
        tooltip: liked
            ? AppLocalizations.of(context)!.unlike
            : AppLocalizations.of(context)!.like,
        onPressed: () {
          liked
              ? removeLiked(widget.mediaItem.id)
              : addItemToPlaylist('Favoritas', widget.mediaItem);

          setState(() {
            liked = !liked;
          });
          ShowSnackBar().showSnackBar(
            context,
            liked
                ? AppLocalizations.of(context)!.addedToFav
                : AppLocalizations.of(context)!.removedFromFav,
            action: SnackBarAction(
                textColor: Theme.of(context).colorScheme.secondary,
                label: AppLocalizations.of(context)!.undo,
                onPressed: () {
                  liked
                      ? removeLiked(widget.mediaItem.id)
                      : addItemToPlaylist('Favoritas', widget.mediaItem);
                  liked = !liked;
                  setState(() {});
                }),
          );
        });
  }
}
