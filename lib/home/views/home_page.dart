import 'package:flutter/material.dart';
import 'package:zonetwo/musics_overview/views/musics_overview_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        const MusicsOverviewPage(),
        const Center(
          child: Text('Business'),
        ),
        const Center(
          child: Text('School'),
        ),
      ][_selectedIndex],
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
    );
  }
}
