import 'package:flutter/material.dart';
import '../entities/playlist_entity.dart';

class PlaylistListTile extends StatelessWidget {
  const PlaylistListTile({
    required this.playlist,
    super.key,
    this.onTap,
  });

  final PlaylistEntity playlist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
        key: Key('todoListTile_${playlist.id}'),
        child: InkWell(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: theme.highlightColor)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: const SizedBox.square(
                      dimension: 80,
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      playlist.name,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                    textColor: theme.textTheme.bodySmall?.color,
                    subtitle: Text("${playlist.songCount} songs"),
                  ),
                ),
              ],
            )));
  }
}
