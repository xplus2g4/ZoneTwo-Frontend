import 'package:flutter/material.dart';
import 'package:zonetwo/musics_overview/musics_overview.dart';

class MusicListTile extends StatelessWidget {
  const MusicListTile({
    required this.music,
    super.key,
    this.onTap,
  });

  final MusicEntity music;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
        key: Key('todoListTile_${music.id}'),
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
                      music.title,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                    textColor: theme.textTheme.bodySmall?.color,
                    subtitle: Text(
                      music.bpm.round().toString(),
                    ),
                  ),
                ),
              ],
            )));
  }
}
