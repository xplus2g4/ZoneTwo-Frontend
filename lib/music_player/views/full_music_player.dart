import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zonetwo/music_overview/entities/music_entity.dart';
import 'package:zonetwo/music_player/music_player.dart';

class FullMusicPlayer extends StatefulWidget {
  const FullMusicPlayer({super.key});

  @override
  State<FullMusicPlayer> createState() => _FullMusicPlayerState();
}

class _FullMusicPlayerState extends State<FullMusicPlayer> {
  late final MusicPlayerBloc _musicPlayerBloc;
  PlayerState _audioPlayerState = PlayerState.stopped;
  Duration _audioPlayerPosition = Duration.zero;
  Duration _audioPlayerDuration = Duration.zero;
  late String _playlistName;
  late num _bpm;
  late int _playlistIndex;
  late int _shuffledIndex;
  late bool _isShuffle;
  late bool _isLoop;
  late bool _isBPMSync;
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
    _playlistIndex = _musicPlayerBloc.state.playlistIndex;
    _shuffledIndex = _musicPlayerBloc.state.shuffledIndex;
    _playlistName = _musicPlayerBloc.state.playlistName;
    _bpm = _musicPlayerBloc.state.bpm;
    _isShuffle = _musicPlayerBloc.state.isShuffle;
    _isLoop = _musicPlayerBloc.state.isLoop;
    _isBPMSync = _musicPlayerBloc.state.isBPMSync;
    _colors = [];

    getDominantColors(getCurrentMusic()!.coverImage).then((value) {
      setState(() {
        _colors = value;
      });
    });

    _audioPlayerState = _musicPlayerBloc.state.audioPlayerState;
    _audioPlayerPosition = _musicPlayerBloc.state.audioPlayerPosition;
    _audioPlayerDuration = _musicPlayerBloc.state.audioPlayerDuration;
  }

  Future<List<Color>> getDominantColors(Uint8List bytes) {
    return PaletteGenerator.fromImageProvider(
      Image.memory(bytes).image,
    ).then((value) =>
        value.paletteColors.map((e) => e.color).toList(growable: false));
  }

  MusicEntity? getCurrentMusic() {
    if (_musicPlayerBloc.state.playlistQueue.isEmpty) {
      return null;
    }
    return !_isShuffle
        ? (_playlistIndex >= 0 &&
                _playlistIndex < _musicPlayerBloc.state.playlistQueue.length)
            ? _musicPlayerBloc.state.playlistQueue[_playlistIndex]
            : null
        : (_shuffledIndex >= 0 &&
                _shuffledIndex < _musicPlayerBloc.state.shuffledQueue.length)
            ? _musicPlayerBloc.state.shuffledQueue[_shuffledIndex]
            : null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerBloc, MusicPlayerState>(
      listenWhen: (previous, current) =>
          previous.playlistIndex != current.playlistIndex ||
          previous.shuffledIndex != current.shuffledIndex ||
          previous.isShuffle != current.isShuffle ||
          previous.isLoop != current.isLoop ||
          previous.isBPMSync != current.isBPMSync ||
          previous.audioPlayerState != current.audioPlayerState,
      listener: (context, state) {
        setState(() {
          _playlistIndex = state.playlistIndex;
          _shuffledIndex = state.shuffledIndex;
          _isShuffle = state.isShuffle;
          _isLoop = state.isLoop;
          _isBPMSync = state.isBPMSync;
          _audioPlayerState = state.audioPlayerState;
        });
        getDominantColors(getCurrentMusic()!.coverImage).then((value) {
          setState(() {
            _colors = value;
          });
        }); 
      },
      child: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
          builder: (context, state) {
        final currentMusic = getCurrentMusic();
        return currentMusic == null
            ? const SizedBox.shrink()
            : Container(
                    decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                    _colors.isEmpty ? Colors.grey[700]! : _colors[0],
                    _colors.isEmpty ? Colors.grey[300]! : _colors[1]
                  ], begin: Alignment.topRight, end: Alignment.bottomLeft),
                    ),
                    child: Scaffold(
                      appBar: AppBar(
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back,
                          shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  color: Colors.black,
                                  blurRadius: 3.0,
                                )
                              ],
                              color: Colors.white70),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        backgroundColor: Colors.transparent,
                        actions: [
                          IconButton(
                        icon: Icon(Icons.graphic_eq,
                            shadows: const <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                color: Colors.black45,
                                blurRadius: 3.0,
                              )
                            ],
                            color: _isBPMSync
                                ? const Color.fromARGB(255, 0, 174, 255)
                                : Colors.white70),
                        onPressed: () => _musicPlayerBloc
                            .add(const MusicPlayerToggleBPMSync()),
                      ),
                      IconButton(
                        icon: Icon(Icons.loop,
                            shadows: const <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                color: Colors.black45,
                                blurRadius: 3.0,
                              )
                            ],
                            color: _isLoop
                                ? const Color.fromARGB(255, 0, 174, 255)
                                : Colors.white70),
                        onPressed: () =>
                            _musicPlayerBloc.add(const MusicPlayerToggleLoop()),
                      ),
                      IconButton(
                              icon: Icon(Icons.shuffle,
                                  shadows: const <Shadow>[
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      color: Colors.black45,
                                      blurRadius: 3.0,
                                    )
                                  ],
                                  color: _isShuffle
                                      ? const Color.fromARGB(255, 0, 174, 255)
                                      : Colors.white60),
                              onPressed: () => _musicPlayerBloc
                                  .add(const MusicPlayerToggleShuffle())),
                        ],
                      ),
                      backgroundColor: Colors.transparent,
                      body: Builder(builder: (context) {
                        return Column(
                            mainAxisAlignment: MainAxisAlignment
                                .center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Currently playing from ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    shadows: <Shadow>[
                                      Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 1.0,
                                          color: Colors.black),
                                    ],
                                    fontSize: 9,
                                  )),
                              Text(_playlistName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    shadows: <Shadow>[
                                      Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 1.0,
                                          color: Colors.black),
                                    ],
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.memory(
                                  currentMusic.coverImage,
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                  width: 300,
                                  child: Text(
                                    currentMusic.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        shadows: <Shadow>[
                                          Shadow(
                                              offset: Offset(1.0, 1.0),
                                              blurRadius: 3.0,
                                              color: Colors.black),
                                          Shadow(
                                              offset: Offset(1.0, 1.0),
                                              blurRadius: 8.0,
                                              color: Colors.black),
                                        ],
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )),
                              const SizedBox(height: 16),
                              BlocListener<MusicPlayerBloc, MusicPlayerState>(
                                  listenWhen: (previous, current) =>
                                      previous.audioPlayerPosition !=
                                          current.audioPlayerPosition ||
                                      previous.audioPlayerDuration !=
                                          current.audioPlayerDuration,
                                  listener: (context, state) {
                                    setState(() {
                                      _audioPlayerPosition =
                                          state.audioPlayerPosition;
                                      _audioPlayerDuration =
                                          state.audioPlayerDuration;
                                    });
                                  },
                                  child: SizedBox(
                                      width: 360,
                                      child: ProgressBar(
                                        progress: _audioPlayerPosition,
                                        total: _audioPlayerDuration,
                                        thumbRadius: 0,
                                        timeLabelPadding: 4,
                                        timeLabelLocation:
                                            TimeLabelLocation.below,
                                        timeLabelType: TimeLabelType.totalTime,
                                        timeLabelTextStyle: const TextStyle(
                                            shadows: <Shadow>[
                                              Shadow(
                                                  offset: Offset(1.0, 1.0),
                                                  blurRadius: 3.0,
                                                  color: Colors.black),
                                            ],
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
                                    baseBarColor: _colors.isEmpty
                                        ? Colors.grey[300]!
                                        : _colors[0],
                                    progressBarColor: Colors.white54,
                                      ))),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _musicPlayerBloc
                                        .add(const MusicPlayerPlayPrevious()),
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      backgroundColor: Colors.black87,
                                      padding: const EdgeInsets.all(12),
                                    ),
                                    child: const Icon(Icons.skip_previous,
                                        color: Colors.white70),
                                  ),
                                  if (_audioPlayerState == PlayerState.playing)
                                    ElevatedButton(
                                      onPressed: () => _musicPlayerBloc
                                          .add(const MusicPlayerPause()),
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        backgroundColor: Colors.black,
                                        padding: const EdgeInsets.all(16),
                                      ),
                                      child: const Icon(
                                        Icons.pause,
                                        size: 36,
                                        color: Colors.white,
                                      ),
                                    )
                                  else
                                    ElevatedButton(
                                      onPressed: () => _musicPlayerBloc
                                          .add(const MusicPlayerResume()),
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        backgroundColor: Colors.black87,
                                        padding: const EdgeInsets.all(16),
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        size: 36,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ElevatedButton(
                                    onPressed: () => _musicPlayerBloc
                                        .add(const MusicPlayerPlayNext()),
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      backgroundColor: Colors.black,
                                      padding: const EdgeInsets.all(12),
                                    ),
                                    child: const Icon(
                                      Icons.skip_next,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                          const SizedBox(height: 16),
                          Stack(
                            children: [
                              Container(
                                width: 250,
                                padding: const EdgeInsets.all(16),
                                foregroundDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: _isBPMSync
                                        ? Colors.transparent
                                        : Colors.black54),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.black12),
                                child: Column(children: [
                                  const Text("Adjusted to",
                                      style: TextStyle(
                                          color: Colors.white,
                                          shadows: <Shadow>[
                                            Shadow(
                                                offset: Offset(1.0, 1.0),
                                                blurRadius: 3.0,
                                                color: Colors.black),
                                          ],
                                          fontWeight: FontWeight.bold)),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Center children vertically
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        IconButton(
                                            onPressed: _isBPMSync
                                                ? () {
                                              setState(() {
                                                _bpm -= 1;
                                              });
                                              _musicPlayerBloc
                                                  .add(MusicPlayerSetBpm(_bpm));
                                                  }
                                                : null,
                                            icon: const Icon(Icons.remove,
                                                color: Colors.white),
                                            iconSize: 36),
                                        const SizedBox(width: 16),
                                        BlocListener<MusicPlayerBloc,
                                                MusicPlayerState>(
                                            listenWhen: (previous, current) =>
                                                previous.bpm != current.bpm,
                                            listener: (context, state) {
                                              setState(() {
                                                _bpm = state.bpm;
                                              });
                                            },
                                            child: Text(
                                              _bpm.round().toString(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  shadows: <Shadow>[
                                                    Shadow(
                                                      offset: Offset(1.0, 1.0),
                                                      blurRadius: 3.0,
                                                      color: Colors.black,
                                                    ),
                                                  ],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 40),
                                            )),
                                        const SizedBox(width: 16),
                                        IconButton(
                                          onPressed: _isBPMSync
                                              ? () {
                                            setState(() {
                                              _bpm += 1;
                                            });
                                            _musicPlayerBloc
                                                .add(MusicPlayerSetBpm(_bpm));
                                                }
                                              : null,
                                          icon: const Icon(Icons.add,
                                              color: Colors.white),
                                          iconSize: 36,
                                        )
                                      ]),
                                  const Text(
                                    "BPM",
                                    style: TextStyle(
                                      color: Colors.white,
                                      shadows: <Shadow>[
                                        Shadow(
                                            offset: Offset(1.0, 1.0),
                                            blurRadius: 3.0,
                                            color: Colors.black),
                                      ],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Originally ${currentMusic.bpm.round().toString()}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      shadows: <Shadow>[
                                        Shadow(
                                            offset: Offset(1.0, 1.0),
                                            blurRadius: 3.0,
                                            color: Colors.black),
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                            ]);
                      }),
                    ),
              );
      }),
    );
  }
}
