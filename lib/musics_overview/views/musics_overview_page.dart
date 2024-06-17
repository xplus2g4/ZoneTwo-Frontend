import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:zonetwo/musics_overview/musics_overview.dart';

class MusicsOverviewPage extends StatelessWidget {
  const MusicsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MusicsOverviewBloc(
        musicRepository: context.read<MusicRepository>(),
      )..add(const MusicsOverviewSubscriptionRequested()),
      child: MusicsOverviewView(),
    );
  }
}

class MusicsOverviewView extends StatelessWidget {
  MusicsOverviewView({super.key}) : player = AudioPlayer();

  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Musics"),
      ),
      body: BlocListener<MusicsOverviewBloc, MusicsOverviewState>(
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
        child: BlocBuilder<MusicsOverviewBloc, MusicsOverviewState>(
          builder: (context, state) {
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
                  ),
                );
              }
            }

            return Scaffold(
              floatingActionButton: MusicsOverviewDownloadButton(),
              body: ListView.builder(
                itemCount: state.musics.length,
                itemBuilder: (context, index) => MusicListTile(
                  music: state.musics[index],
                  onTap: () {
                    if (player.state == PlayerState.playing) {
                      player.stop();
                    }
                    player
                        .setSourceDeviceFile(state.musics[index].savePath)
                        .then((_) => player.resume());
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
