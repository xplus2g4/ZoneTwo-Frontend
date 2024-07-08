import 'package:flutter/material.dart';
import 'package:zonetwo/music_overview/music_overview.dart';

class MusicListTile extends StatelessWidget {
  const MusicListTile({
    required this.music,
    required this.isSelectionMode,
    required this.isSelected,
    super.key,
    this.onTap,
    this.onLongPress,
  });

  final MusicEntity music;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
        key: Key('todoListTile_${music.id}'),
        child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: theme.highlightColor)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.memory(
                      music.coverImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
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
                      "BPM: ${music.bpm.round()}",
                    ),
                  ),
                ),
                isSelectionMode
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (bool? x) {
                          onTap!();
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            )));
  }
}
