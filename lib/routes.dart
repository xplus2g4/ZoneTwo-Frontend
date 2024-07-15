import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zonetwo/home/home.dart';
import 'package:zonetwo/music_overview/music_overview.dart';
import 'package:zonetwo/playlist_detail/playlist_detail.dart';
import 'package:zonetwo/playlists_overview/playlists_overview.dart';

//tabs keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _musicOverviewNavigatorKey = GlobalKey<NavigatorState>();
final _playlistOverviewNavigatorKey = GlobalKey<NavigatorState>();
final _settingsNavigatorKey = GlobalKey<NavigatorState>();

//pages paths
const musicOverviewPath = '/music_overview';
const playlistOverviewPath = '/playlist_overview';
const playlistDetailPath = 'player_detail';
const settingsPath = '/settings';

final router = GoRouter(
  initialLocation: musicOverviewPath,
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state, child) {
        return NoTransitionPage(
          child: HomePage(
            child: child,
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _musicOverviewNavigatorKey,
          routes: [
            GoRoute(
              path: musicOverviewPath,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const MusicOverviewPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _playlistOverviewNavigatorKey,
          routes: [
            GoRoute(
              path: playlistOverviewPath,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const PlaylistsOverviewPage(),
              ),
              routes: [
                GoRoute(
                  name: playlistDetailPath,
                  path: playlistDetailPath,
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: PlaylistDetailPage(state.extra as PlaylistEntity),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: settingsPath,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const Center(
                  child: Text('School'),
                ),
              ),
            ),
          ],
        ),
      ],
    )
  ],
);
