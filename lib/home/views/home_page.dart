import 'package:flutter/material.dart';
import 'package:zonetwo/music_download/widgets/share_media_listener.dart';
import 'package:zonetwo/music_player/music_player.dart';
import 'package:zonetwo/music_overview/views/music_overview_page.dart';
import 'package:zonetwo/playlists_overview/views/playlists_overview_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ShareMediaListener(
      child: Scaffold(
        body: Scaffold(
          body: [
            const MusicsOverviewPage(),
            const PlaylistsOverviewPage(),
            const Center(
              child: Text('School'),
            ),
          ][_selectedIndex],
          bottomNavigationBar: const FloatingMusicPlayer(),
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          indicatorColor: Theme.of(context).colorScheme.primary,
          selectedIndex: _selectedIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.music_note),
              label: 'Musics',
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
