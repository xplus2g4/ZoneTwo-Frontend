import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playlist_repository/playlist_repository.dart';

import '../bloc/playlists_overview_bloc.dart';
import '../widgets/playlist_list_tile.dart';

class PlaylistsOverviewPage extends StatelessWidget {
  const PlaylistsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlaylistsOverviewBloc(
        playlistRepository: context.read<PlaylistRepository>(),
      )..add(const PlaylistsOverviewSubscriptionRequested()),
      child: const MusicOverviewView(),
    );
  }
}

class MusicOverviewView extends StatelessWidget {
  const MusicOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Playlists"),
      ),
      body: BlocListener<PlaylistsOverviewBloc, PlaylistsOverviewState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == PlaylistsOverviewStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text("Error"),
                ),
              );
          }
        },
        child: BlocBuilder<PlaylistsOverviewBloc, PlaylistsOverviewState>(
          builder: (context, state) {
            if (state.playlists.isEmpty) {
              if (state.status == PlaylistsOverviewStatus.loading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state.status != PlaylistsOverviewStatus.success) {
                return const SizedBox();
              } else {
                return Center(
                  child: Text(
                    "Create your playlist now!",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
            }

            return ListView.builder(
              itemCount: state.playlists.length,
              itemBuilder: (context, index) => PlaylistListTile(
                  playlist: state.playlists[index],
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      'playlist_detail',
                      arguments: state.playlists[index],
                    );
                  }),
            );
          },
        ),
      ),
    );
  }
}
