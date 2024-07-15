import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/music_overview/music_overview.dart';
import 'package:zonetwo/playlist_detail/bloc/playlist_detail_bloc.dart';
import 'package:zonetwo/playlists_overview/playlists_overview.dart';

class PlaylistDetailPage extends StatelessWidget {
  const PlaylistDetailPage(this.playlist, {super.key});

  final PlaylistEntity playlist;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlaylistDetailBloc(
        playlistRepository: context.read<PlaylistRepository>(),
      )..add(PlaylistDetailSubscriptionRequested(playlist)),
      child: PlaylistDetail(playlist),
    );
  }
}

class PlaylistDetail extends StatelessWidget {
  const PlaylistDetail(this.playlist, {super.key});

  final PlaylistEntity playlist;

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
                    child: playlist.coverImage != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16.0),
                              bottomRight: Radius.circular(16.0),
                            ),
                            child: Image.memory(
                              playlist.coverImage!,
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
                    child: ListTile(
                      textColor: Colors.white,
                      title: Text(
                        playlist.name,
                      ),
                      subtitle: Text(
                        '${playlist.songCount} songs',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return MusicListTile(music: state.music[index]);
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
