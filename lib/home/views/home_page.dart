import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zonetwo/music_download/widgets/share_media_listener.dart';
import 'package:zonetwo/music_player/music_player.dart';
import 'package:zonetwo/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.child});

  final StatefulNavigationShell child;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Map<int, String> tabKeys = {
    0: musicOverviewPath,
    1: playlistOverviewPath,
    2: settingsPath,
  };

  @override
  Widget build(BuildContext context) {
    return ShareMediaListener(
      child: Scaffold(
        body: Scaffold(
          body: widget.child,
          bottomNavigationBar: const FloatingMusicPlayer(),
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (index) {
            widget.child.goBranch(index);
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
