import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_repository/music_repository.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/music_player/music_player.dart';
import 'package:zonetwo/music_overview/music_overview.dart';
import 'package:zonetwo/routes.dart';
import 'package:zonetwo/utils/utils.dart';
import 'package:zonetwo/utils/widgets/appbar_actions.dart';

import '../widgets/edit_music_dialog.dart';

class MusicOverviewPage extends StatelessWidget {
  const MusicOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MusicOverviewBloc(
        musicRepository: context.read<MusicRepository>(),
        playlistRepository: context.read<PlaylistRepository>(),
      )..add(const MusicOverviewSubscriptionRequested()),
      child: BlocListener<MusicOverviewBloc, MusicOverviewState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == MusicOverviewStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text("Error"),
                ),
              );
          }
        },
        child: const MusicOverviewView(),
      ),
    );
  }
}

class MusicOverviewView extends StatefulWidget {
  const MusicOverviewView({super.key});

  @override
  MusicOverviewViewState createState() => MusicOverviewViewState();
}

class MusicOverviewViewState extends State<MusicOverviewView> {
  late MusicOverviewBloc _musicOverviewBloc;
  late MusicPlayerBloc _musicPlayerBloc;

  @override
  void initState() {
    super.initState();
    _musicOverviewBloc = context.read<MusicOverviewBloc>();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: "Confirm Delete",
          content: "Are you sure you want to delete the selected music?",
          confirmText: "Delete",
          onCancel: () => Navigator.pop(context),
          onConfirm: () {
            _musicOverviewBloc.add(const MusicOverviewDeleteSelected());
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showEditDialog(MusicEntity music) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return EditMusicDialog(music);
      },
    ).then((bpm) {
      if (bpm != null) {
        _musicOverviewBloc.add(MusicOverviewEditMusic(
          music: MusicEntity(
            id: music.id,
            title: music.title,
            bpm: int.parse(bpm),
            savePath: music.savePath,
            coverImage: music.coverImage,
          ),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicOverviewBloc, MusicOverviewState>(
      builder: (context, state) {
        return Scaffold(
          floatingActionButton: state.isSelectionMode
              ? CreatePlaylistFAB(_musicOverviewBloc)
              : const MusicOverviewDownloadButton(),
          appBar: AppBar(
            title: state.isSelectionMode
                ? Text("${state.selected.length} selected")
                : const Text("All Music"),
            leading: state.isSelectionMode
                ? IconButton(
                    icon: Icon(Icons.close,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      _musicOverviewBloc
                          .add(const MusicOverviewExitSelectionMode());
                    },
                  )
                : null,
            actions: state.isSelectionMode
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: state.selected.length != 1
                          ? null
                          : () => _showEditDialog(
                                state.music.firstWhere(
                                  (element) =>
                                      element.id == state.selected.first,
                                ),
                              ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Theme.of(context).colorScheme.error,
                      onPressed: state.selected.isEmpty
                          ? null
                          : () => _showDeleteDialog(context),
                    ),
                  ]
                : AppBarActions.getActions(),
          ),
          body: Builder(
            builder: (context) {
              if (state.music.isEmpty) {
                if (state.status == MusicOverviewStatus.loading) {
                  return const Center(child: CupertinoActivityIndicator());
                } else if (state.status != MusicOverviewStatus.success) {
                  return const SizedBox();
                } else {
                  return Center(
                      child: Text(
                    "Add your music now!",
                    style: Theme.of(context).textTheme.bodySmall,
                  ));
                }
              }
              return ListView.builder(
                  itemCount: state.music.length,
                  itemBuilder: (context, index) {
                    final currentMusic = state.music[index];
                    return MusicListTile(
                      music: currentMusic,
                      isSelectionMode: state.isSelectionMode,
                      isSelected: state.selected.contains(currentMusic.id),
                      onTap: () {
                        if (state.isSelectionMode) {
                          _musicOverviewBloc.add(
                              MusicOverviewToggleSelectedMusic(
                                  currentMusic.id));
                        } else {
                          _musicPlayerBloc.add(MusicPlayerQueueMusic(
                              state.music, 'All Music',
                              playMusicEntity: currentMusic));
                        }
                      },
                      onLongPress: () {
                        _musicOverviewBloc.add(
                            MusicOverviewEnterSelectionMode(currentMusic.id));
                      },
                    );
                  });
            },
          ),
        );
      },
    );
  }
}
