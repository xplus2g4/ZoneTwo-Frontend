import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zonetwo/music_player/music_player.dart';

class FullMusicPlayer extends StatefulWidget {
  const FullMusicPlayer({super.key});

  @override
  State<FullMusicPlayer> createState() => _FullMusicPlayerState();
}

class _FullMusicPlayerState extends State<FullMusicPlayer> {
  late final MusicPlayerBloc _musicPlayerBloc;
  late final AudioPlayer _audioPlayer;
  PlayerState _audioPlayerState = PlayerState.stopped;
  Duration _audioPlayerPosition = Duration.zero;
  Duration _audioPlayerDuration = Duration.zero;
  num _bpm = 160;

  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<Duration> _durationSubscription;
  late final StreamSubscription<PlayerState> _playerStateSubscription;

  @override
  void dispose() {
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _playerStateSubscription.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
    _audioPlayer = _musicPlayerBloc.state.audioPlayer;
    _bpm = _musicPlayerBloc.state.bpm;

    _audioPlayerState = _musicPlayerBloc.state.audioPlayerState;
    _audioPlayerPosition = _musicPlayerBloc.state.audioPlayerPosition;
    _audioPlayerDuration = _musicPlayerBloc.state.audioPlayerDuration;

    _positionSubscription = _audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        _audioPlayerPosition = event;
      });
      _musicPlayerBloc.add(MusicPlayerPositionChanged(event));
    });
    _durationSubscription = _audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        _audioPlayerDuration = event;
      });
      _musicPlayerBloc.add(MusicPlayerDurationChanged(event));
    });
    _playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((event) {
      _audioPlayerState = event;
      if (event == PlayerState.completed) {
        // TODO: Implement next music
      }
    });
  }

  Future<List<Color>> getDominantColor(Uint8List bytes) {
    return PaletteGenerator.fromImageProvider(
      Image.memory(bytes).image,
    ).then(
        (value) => [value.dominantColor!.color, value.darkVibrantColor!.color]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerBloc, MusicPlayerState>(
      listenWhen: (previous, current) =>
          previous.bpm != current.bpm ||
          previous.audioPlayerState != current.audioPlayerState ||
          previous.audioPlayerPosition != current.audioPlayerPosition ||
          previous.audioPlayerDuration != current.audioPlayerDuration,
      listener: (context, state) {
        setState(() {
          _bpm = state.bpm;
          _audioPlayerState = state.audioPlayerState;
          _audioPlayerPosition = state.audioPlayerPosition;
          _audioPlayerDuration = state.audioPlayerDuration;
        });
      },
      child: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
          builder: (context, state) {
        final currMusic = state.currentIndex == -1
            ? null
            : state.musicQueue[state.currentIndex];

        return currMusic == null
            ? const SizedBox.shrink()
            : FutureBuilder(
                future: getDominantColor(currMusic.coverImage),
                builder: (context, colorSnapshot) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          colorSnapshot.data?[0] ?? Colors.grey[700]!,
                          colorSnapshot.data?[1] ?? Colors.grey[700]!,
                        ],
                      ),
                    ),
                    child: Scaffold(
                      appBar: AppBar(
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        backgroundColor: colorSnapshot.data?[0] ??
                            Theme.of(context).primaryColor,
                      ),
                      backgroundColor: Colors.transparent,
                      body: Builder(builder: (context) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center children vertically
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 64),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.memory(
                                    currMusic.coverImage,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Original\n BPM",
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      currMusic.bpm.round().toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                    // Add more text widgets here as needed
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                                width: 300,
                                child: Text(
                                  currMusic.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )),
                            const SizedBox(height: 16),
                            SizedBox(
                                width: 360,
                                child: ProgressBar(
                                  progress: _audioPlayerPosition,
                                  total: _audioPlayerDuration,
                                  thumbRadius: 0,
                                  timeLabelPadding: 4,
                                  timeLabelLocation: TimeLabelLocation.below,
                                  timeLabelType: TimeLabelType.totalTime,
                                  timeLabelTextStyle: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  onSeek: (position) {
                                    setState(() {
                                      _audioPlayerPosition = position;
                                    });
                                    _musicPlayerBloc
                                        .add(MusicPlayerSeek(position));
                                  },
                                  barHeight: 8,
                                  baseBarColor:
                                      colorSnapshot.data?[0] ?? Colors.white12,
                                  progressBarColor: Colors.white54,
                                )),
                            if (state.audioPlayer.state == PlayerState.playing)
                              IconButton(
                                  onPressed: () => _musicPlayerBloc
                                      .add(const MusicPlayerPause()),
                                  iconSize: 36,
                                  icon: const Icon(Icons.pause))
                            else
                              IconButton(
                                  onPressed: () {
                                    _musicPlayerBloc
                                        .add(const MusicPlayerResume());
                                  },
                                  iconSize: 36,
                                  icon: const Icon(Icons.play_arrow)),
                            const SizedBox(height: 36),
                            const Text("Adjusted to",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center children vertically
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _bpm -= 1;
                                        });
                                        _musicPlayerBloc
                                            .add(MusicPlayerSetBpm(_bpm));
                                      },
                                      icon: const Icon(Icons.remove),
                                      iconSize: 36),
                                  const SizedBox(width: 16),
                                  Text(
                                    _bpm.round().toString(),
                                    style: const TextStyle(fontSize: 48),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _bpm += 1;
                                        });
                                        _musicPlayerBloc
                                            .add(MusicPlayerSetBpm(_bpm));
                                      },
                                      icon: const Icon(Icons.add),
                                      iconSize: 36),
                                ]),
                            const Text("BPM",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        );
                      }),
                    ),
                  );
                });
      }),
    );
  }
}

class PositionData {
  final Duration position;
  final Duration duration;

  PositionData(this.position, this.duration);
}
