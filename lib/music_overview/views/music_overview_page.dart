import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/music_player/music_player.dart';
import 'package:zonetwo/music_overview/music_overview.dart';

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
              ? Text(
                  "${state.selected.where((selected) => selected).length} selected")
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
                    icon: Icon(Icons.delete,
                        color: Theme.of(context).colorScheme.error),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text(
                                "Are you sure you want to delete the selected music?"),
                            actions: <Widget>[
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                              ),
                              TextButton(
                                child: const Text("Delete"),
                                onPressed: () {
                                  // Perform the delete operation
                                  _musicOverviewBloc.add(
                                      MusicOverviewDeleteSelected(state.music
                                          .asMap()
                                          .entries
                                          .where((music) =>
                                              state.selected[music.key])
                                          .map((music) => music.value)));
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ]
              : null,
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
              itemBuilder: (context, index) => MusicListTile(
                music: state.music[index],
                isSelectionMode: state.isSelectionMode,
                isSelected: state.selected[index],
                onTap: () {
                  if (state.isSelectionMode) {
                    _musicOverviewBloc
                        .add(MusicOverviewToggleSelectedMusic(index));
                  } else {
                    _musicPlayerBloc
                        .add(MusicPlayerInsertNext(state.music[index]));
                  }
                },
                onLongPress: () {
                  _musicOverviewBloc
                      .add(MusicOverviewEnterSelectionMode(index));
                },
              ),
            );
          },
        ),
      );
    });
  }
}

