import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zonetwo/home/home.dart';
import 'package:zonetwo/music_overview/music_overview.dart';
import 'package:zonetwo/playlist_detail/playlist_detail.dart';
import 'package:zonetwo/playlists_overview/playlists_overview.dart';
import 'package:zonetwo/workout_detail/views/workout_detail_page.dart';
import 'package:zonetwo/workout_overview/views/workout_overview_page.dart';
import 'package:zonetwo/workout_page/views/workout_page.dart';

import 'settings/settings.dart';

//tabs keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _musicOverviewNavigatorKey = GlobalKey<NavigatorState>();
final _playlistOverviewNavigatorKey = GlobalKey<NavigatorState>();
final _workoutOverviewNavigatorKey = GlobalKey<NavigatorState>();
final _settingsNavigatorKey = GlobalKey<NavigatorState>();

//pages paths
const musicOverviewPath = '/music_overview';
const playlistOverviewPath = '/playlist_overview';
const playlistDetailPath = 'player_detail';
const workoutOverviewPath = '/workout_overview';
const workoutDetailPath = 'workout_detail';
const workoutPage = 'workout_page';

const settingsPath = '/settings';
const settingsEditFieldPath = 'edit_field';
const settingsFaqPath = 'faq';

final router = GoRouter(
  initialLocation: musicOverviewPath,
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
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
            navigatorKey: _workoutOverviewNavigatorKey,
            routes: [
              GoRoute(
                path: workoutOverviewPath,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const WorkoutOverviewPage(),
                ),
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    name: workoutPage,
                    path: workoutPage,
                    pageBuilder: (context, state) {
                      final args = state.extra as WorkoutPageArguments;
                      return MaterialPage(
                        key: state.pageKey,
                        child: WorkoutPage(
                          datetime: args.datetime,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                      parentNavigatorKey: _workoutOverviewNavigatorKey,
                      name: workoutDetailPath,
                      path: workoutDetailPath,
                      pageBuilder: (context, state) {
                        final args = state.extra as WorkoutDetailPageArguments;
                        return MaterialPage(
                          key: state.pageKey,
                          child: WorkoutDetailPage(
                            workout: args.workout,
                          ),
                        );
                      }),
                ],
              )
            ]),
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: settingsPath,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const SettingsPage(),
              ),
              routes: [
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  name: settingsEditFieldPath,
                  path: settingsEditFieldPath,
                  pageBuilder: (context, state) {
                    final args = state.extra as FieldEditPageArguments;
                    return MaterialPage(
                      key: state.pageKey,
                      child: FieldEditPage(
                        fieldName: args.fieldName,
                        initialValue: args.initialValue,
                        onConfirm: args.onConfirm,
                      ),
                    );
                  },
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  name: settingsFaqPath,
                  path: settingsFaqPath,
                  pageBuilder: (context, state) => MaterialPage(
                    key: state.pageKey,
                    child: const FaqPage(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    )
  ],
);
