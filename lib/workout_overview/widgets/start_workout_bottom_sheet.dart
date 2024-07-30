import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/music_player/bloc/music_player_bloc.dart';
import 'package:zonetwo/playlists_overview/bloc/playlists_overview_bloc.dart';
import 'package:zonetwo/playlists_overview/entities/playlist_entity.dart';
import 'package:zonetwo/routes.dart';
import 'package:zonetwo/workout_page/views/workout_page.dart';

class StartWorkoutBottomSheet extends StatefulWidget {
  const StartWorkoutBottomSheet({super.key});

  @override
  StartWorkoutBottomSheetState createState() => StartWorkoutBottomSheetState();
}

class StartWorkoutBottomSheetState extends State<StartWorkoutBottomSheet> {
  PlaylistEntity _selectedPlaylist = PlaylistEntity.ALL_MUSIC;
  late final MusicPlayerBloc _musicPlayerBloc;

  @override
  void initState() {
    super.initState();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => PlaylistsOverviewBloc(
              playlistRepository: context.read<PlaylistRepository>(),
            )..add(const PlaylistsOverviewSubscriptionRequested()),
        child: SizedBox(
          height: 700,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Select workout playlist",
                      style: TextStyle(fontSize: 20),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          _musicPlayerBloc.add(const MusicPlayerStop());
                          if (_selectedPlaylist == PlaylistEntity.ALL_MUSIC) {
                            _musicPlayerBloc
                                .add(const MusicPlayerQueueAllMusic());
                          } else {
                            _musicPlayerBloc.add(MusicPlayerQueuePlaylistMusic(
                                _selectedPlaylist));
                          }
                          
                          context.pop();
                          context.pushNamed(
                            workoutPage,
                            extra: WorkoutPageArguments(
                              startDatetime: DateTime.now(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.directions_run, color: Colors.red[100]),
                            const SizedBox(width: 8),
                            Text('Go!',
                                style: TextStyle(
                                    color: Colors.red[100],
                                    fontWeight: FontWeight.bold))
                          ],
                        )),
                  ],
                ),
              ),
              Expanded(child:
                  BlocBuilder<PlaylistsOverviewBloc, PlaylistsOverviewState>(
                builder: (context, state) {
                  final playlists = [
                    PlaylistEntity.ALL_MUSIC,
                    ...state.playlists
                  ];
                  return ListView.builder(
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        return Material(
                            child: ListTile(
                          selected: _selectedPlaylist == playlist,
                          selectedTileColor:
                              Theme.of(context).colorScheme.primary,
                          selectedColor: Colors.black,
                          leading: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                    color: Theme.of(context).highlightColor)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: playlist.coverImage != null
                                  ? Image.memory(
                                      playlist.coverImage!,
                                      fit: BoxFit.cover,
                                      width: 50,
                                      height: 50,
                                    )
                                  : const Icon(Icons.music_note, size: 50),
                            ),
                          ),
                          title: Text(playlist.name),
                          trailing: _selectedPlaylist == playlist
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedPlaylist = playlist;
                            });
                          },
                        ));
                      });
                },
              )),
            ],
          ),
        ));
  }
}
