import 'package:flutter/material.dart';
import 'package:zonetwo/music_download/widgets/share_media_listener.dart';
import 'package:zonetwo/music_player/music_player.dart';
import 'package:zonetwo/music_overview/views/music_overview_page.dart';
import 'package:zonetwo/playlist_detail/views/playlist_detail_page.dart';
import 'package:zonetwo/playlists_overview/playlists_overview.dart';
import 'package:zonetwo/playlists_overview/views/playlists_overview_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Map<int, String> tabKeys = {
    0: "music_overview",
    1: "playlists_overview",
    2: "school",
  };
  Map<int, GlobalKey<NavigatorState>> navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
  };

  @override
  Widget build(BuildContext context) {
    return ShareMediaListener(
      child: Scaffold(
        body: Scaffold(
          body: Navigator(
            key: navigatorKeys[_selectedIndex],
            onGenerateRoute: (settings) {
              Widget page;
              if (settings.name == 'playlist_detail') {
                page = PlaylistDetailPage(settings.arguments as PlaylistEntity);
              } else {
                page = [
                  const MusicOverviewPage(),
                  const PlaylistsOverviewPage(),
                  const Center(
                    child: Text('School'),
                  )
                ][_selectedIndex];
              }
              return MaterialPageRoute(builder: (_) => page);
            },
          ),
          bottomNavigationBar: const FloatingMusicPlayer(),
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (index) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            setState(() {
              _selectedIndex = index;
            });
          },
          indicatorColor: Theme.of(context).colorScheme.primary,
          selectedIndex: _selectedIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.music_note),
              label: 'Music',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_music),
              label: 'Playlists',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
