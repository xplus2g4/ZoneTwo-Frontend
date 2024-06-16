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
    return ListTile(
      key: Key('todoListTile_${music.id}'),
      title: Text(
        music.title,
        maxLines: 2,
        overflow: TextOverflow.fade,
      ),
      onTap: onTap,
      subtitle: Text(
        music.bpm.round().toString(),
      ),
    );
  }
}
