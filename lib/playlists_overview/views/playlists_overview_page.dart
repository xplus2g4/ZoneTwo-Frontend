import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/playlists_overview/playlists_overview.dart';
import 'package:zonetwo/routes.dart';
import 'package:zonetwo/utils/widgets/appbar_actions.dart';

import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/playlist_list_tile.dart';

class PlaylistsOverviewPage extends StatelessWidget {
  const PlaylistsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlaylistsOverviewBloc(
        playlistRepository: context.read<PlaylistRepository>(),
      )..add(const PlaylistsOverviewSubscriptionRequested()),
      child: const PlaylistOverviewView(),
    );
  }
}

class PlaylistOverviewView extends StatefulWidget {
  const PlaylistOverviewView({super.key});

  @override
  State<PlaylistOverviewView> createState() => _PlaylistOverviewViewState();
}

class _PlaylistOverviewViewState extends State<PlaylistOverviewView> {
  bool _isSelectionMode = false;
  Set<String> _selectedPlaylists = {};

  void _enterSelectionMode(PlaylistEntity playlist) {
    setState(() {
      _isSelectionMode = true;
      _selectedPlaylists = {};
    });
    _toggleSelection(playlist);
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedPlaylists = {};
    });
  }

  void _toggleSelection(PlaylistEntity playlist) {
    setState(() {
      if (_selectedPlaylists.contains(playlist.id)) {
        _selectedPlaylists.remove(playlist.id);
      } else {
        _selectedPlaylists.add(playlist.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaylistsOverviewBloc, PlaylistsOverviewState>(
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
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            leading: _isSelectionMode
                ? IconButton(
                    onPressed: _exitSelectionMode,
                    icon: const Icon(Icons.close))
                : null,
            title: const Text("All Playlists"),
            actions: _isSelectionMode
                ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Theme.of(context).colorScheme.error,
                  disabledColor: Theme.of(context).disabledColor,
                  onPressed: _selectedPlaylists.isEmpty
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const DeleteConfirmationDialog(),
                          ).then((value) {
                            if (value == true) {
                              context.read<PlaylistsOverviewBloc>().add(
                                    PlaylistsOverviewPlaylistsDeleted(
                                        _selectedPlaylists),
                                  );
                              _exitSelectionMode();
                            }
                          });
                        },
                    )
                  ]
                : AppBarActions.getActions(),
          ),
          body: Builder(
            builder: (context) {
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
                    if (_isSelectionMode) {
                      _toggleSelection(state.playlists[index]);
                    } else {
                      context.goNamed(playlistDetailPath,
                          extra: state.playlists[index]);
                    }
                  },
                  onLongPress: () {
                    _enterSelectionMode(state.playlists[index]);
                  },
                  isSelectionMode: _isSelectionMode,
                  isSelected:
                      _selectedPlaylists.contains(state.playlists[index].id),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
