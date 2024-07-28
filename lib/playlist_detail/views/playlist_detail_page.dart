import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/music_overview/music_overview.dart';
import 'package:zonetwo/music_player/music_player.dart';
import 'package:zonetwo/playlist_detail/bloc/playlist_detail_bloc.dart';
import 'package:zonetwo/playlists_overview/playlists_overview.dart';

import '../widgets/remove_confirmation_dialog.dart';

class PlaylistDetailPage extends StatelessWidget {
  const PlaylistDetailPage(this.playlist, {super.key});

  final PlaylistEntity playlist;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlaylistDetailBloc(
        playlist: playlist,
        playlistRepository: context.read<PlaylistRepository>(),
      )..add(PlaylistDetailSubscriptionRequested(playlist)),
      child: const PlaylistDetail(),
    );
  }
}

class PlaylistDetail extends StatefulWidget {
  const PlaylistDetail({super.key});

  @override
  State<PlaylistDetail> createState() => _PlaylistDetailState();
}

class _PlaylistDetailState extends State<PlaylistDetail> {
  late final MusicPlayerBloc _musicPlayerBloc;
  bool _isSelectionMode = false;
  Set<String> _selectedMusic = {};

  @override
  void initState() {
    super.initState();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
  }

  void _enterSelectionMode(MusicEntity music) {
    setState(() {
      _selectedMusic = {};
      _isSelectionMode = true;
    });
    _selectedMusic.add(music.id);
  }

  void _toggleSelection(MusicEntity music) {
    setState(() {
      if (_selectedMusic.contains(music.id)) {
        _selectedMusic.remove(music.id);
      } else {
        _selectedMusic.add(music.id);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
    });
  }

  void _removeSelectedMusic(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) => const RemoveConfirmationDialog(),
    ).then((confirmDelete) {
      if (confirmDelete == true) {
        context.read<PlaylistDetailBloc>().add(
              PlaylistMusicDeleted(_selectedMusic),
            );
        _exitSelectionMode();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<PlaylistDetailBloc, PlaylistDetailState>(
      builder: (context, state) {
        return CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              leading: Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: const ShapeDecoration(
                      color: Colors.black,
                      shape: CircleBorder(),
                    ),
                    child: const BackButton(),
                  )),
              expandedHeight: 160.0,
              collapsedHeight: 160.0,
              flexibleSpace: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: state.playlist.coverImage != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16.0),
                              bottomRight: Radius.circular(16.0),
                            ),
                            child: Image.memory(
                              state.playlist.coverImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : null,
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: _isSelectionMode
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.close,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    onPressed: _exitSelectionMode,
                                  ),
                                  Text(
                                    '${_selectedMusic.length} selected',
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Theme.of(context).colorScheme.error,
                                disabledColor:
                                    Theme.of(context).colorScheme.secondary,
                                onPressed: _selectedMusic.isEmpty
                                    ? null
                                    : () => _removeSelectedMusic(context),
                              ),
                            ],
                          )
                        : PlaylistMetadata(
                            state.playlist,
                            onNameChanged: (name) {
                              context.read<PlaylistDetailBloc>().add(
                                    PlaylistNameChanged(name),
                                  );
                            },
                          ),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final currMusic = state.music[index];
                  return MusicListTile(
                    music: currMusic,
                    isSelectionMode: _isSelectionMode,
                    isSelected: _selectedMusic.contains(currMusic.id),
                    onLongPress: () => _enterSelectionMode(currMusic),
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleSelection(currMusic);
                      } else {
                        _musicPlayerBloc
                            .add(MusicPlayerQueueMusic(state.music));
                        _musicPlayerBloc
                            .add(MusicPlayerPlayThisMusic(state.music[index]));
                      }
                    },
                  );
                },
                childCount: state.music.length,
              ),
            ),
          ],
        );
      },
    ));
  }
}

class PlaylistMetadata extends StatefulWidget {
  const PlaylistMetadata(this.playlist,
      {required this.onNameChanged, super.key});

  final PlaylistEntity playlist;
  final ValueChanged<String> onNameChanged;

  @override
  State<PlaylistMetadata> createState() => _PlaylistMetadataState();
}

class _PlaylistMetadataState extends State<PlaylistMetadata> {
  late final TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playlist.name);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Colors.white,
      title: _isEditing
          ? TextField(
              controller: _nameController,
              onEditingComplete: _submitName,
              onTapOutside: (_) => _submitName(),
              autofocus: true,
              maxLength: 20,
              decoration: const InputDecoration(
                isDense: true,
                counterText: "",
              ),
            )
          : Text(
              widget.playlist.name,
            ),
      subtitle: Text(
        '${widget.playlist.songCount} songs',
      ),
      onTap: () {
        setState(() {
          _isEditing = true;
        });
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitName() {
    setState(() {
      _isEditing = false;
    });
    widget.onNameChanged(_nameController.text);
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
