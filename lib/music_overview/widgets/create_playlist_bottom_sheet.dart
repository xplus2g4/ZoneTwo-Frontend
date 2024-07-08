import 'package:flutter/material.dart';
import 'package:zonetwo/music_overview/music_overview.dart';

class CreatePlaylistBottomSheet extends StatelessWidget {
  const CreatePlaylistBottomSheet(this.musicsOverviewBloc, {super.key});

  final MusicsOverviewBloc musicsOverviewBloc;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _NameField(
              onCreatePlaylist: (String playlistName) => musicsOverviewBloc
                  .add(MusicsOverviewCreatePlaylist(playlistName)),
            ),
          ),
          const Text('Modal BottomSheet'),
          ElevatedButton(
            child: const Text('Close BottomSheet'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _NameField extends StatefulWidget {
  const _NameField({required this.onCreatePlaylist});

  final ValueChanged<String> onCreatePlaylist;

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  final _textController = TextEditingController(text: "New Playlist");

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      autocorrect: false,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Enter playlist name',
        suffixIcon: IconButton(
          icon: const Icon(Icons.playlist_add_check_circle),
          onPressed: () => _onConfirm(context),
        ),
      ),
    );
  }

  void _onConfirm(context) {
    widget.onCreatePlaylist(_textController.text);
    _textController.text = '';
    Navigator.pop(context);
  }
}
