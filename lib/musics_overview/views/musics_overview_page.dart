import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/music_player/music_player.dart';
import 'package:zonetwo/musics_overview/musics_overview.dart';

class MusicsOverviewPage extends StatelessWidget {
  const MusicsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MusicsOverviewBloc(
        musicRepository: context.read<MusicRepository>(),
        playlistRepository: context.read<PlaylistRepository>(),
      )..add(const MusicsOverviewSubscriptionRequested()),
      child: BlocListener<MusicsOverviewBloc, MusicsOverviewState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == MusicsOverviewStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text("Error"),
                ),
              );
          }
        },
        child: const MusicsOverviewView(),
      ),
    );
  }
}

class MusicsOverviewView extends StatefulWidget {
  const MusicsOverviewView({super.key});

  @override
  MusicsOverviewViewState createState() => MusicsOverviewViewState();
}

class MusicsOverviewViewState extends State<MusicsOverviewView> {
  late MusicsOverviewBloc _musicsOverviewBloc;
  late MusicPlayerBloc _musicPlayerBloc;

  @override
  void initState() {
    super.initState();
    _musicsOverviewBloc = context.read<MusicsOverviewBloc>();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicsOverviewBloc, MusicsOverviewState>(
        builder: (context, state) {
      return Scaffold(
        floatingActionButton: state.isSelectionMode
            ? CreatePlaylistFAB(_musicsOverviewBloc)
            : const MusicsOverviewDownloadButton(),
        appBar: AppBar(
          title: const Text("All Musics"),
          leading: state.isSelectionMode
              ? IconButton(
                  icon: Icon(Icons.close,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    _musicsOverviewBloc
                        .add(const MusicOverviewExitSelectionMode());
                  },
                )
              : null,
        ),
        body: Builder(
          builder: (context) {
            if (state.musics.isEmpty) {
              if (state.status == MusicsOverviewStatus.loading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state.status != MusicsOverviewStatus.success) {
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
              itemCount: state.musics.length,
              itemBuilder: (context, index) => MusicListTile(
                music: state.musics[index],
                isSelectionMode: state.isSelectionMode,
                isSelected: state.selected[index],
                onTap: () {
                  if (state.isSelectionMode) {
                    _musicsOverviewBloc
                        .add(MusicOverviewToggleSelectedMusic(index));
                  } else {
                    _musicPlayerBloc
                        .add(MusicPlayerInsertNext(state.musics[index]));
                  }
                },
                onLongPress: () {
                  _musicsOverviewBloc
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
