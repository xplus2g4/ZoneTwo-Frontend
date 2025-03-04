import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zonetwo/music_overview/entities/music_entity.dart';
import 'package:zonetwo/music_player/music_player.dart';
import 'package:zonetwo/music_player/widgets/scrolling_text.dart';

class FloatingMusicPlayer extends StatefulWidget {
  const FloatingMusicPlayer({super.key});

  @override
  State<FloatingMusicPlayer> createState() => FloatingMusicPlayerState();
}

class FloatingMusicPlayerState extends State<FloatingMusicPlayer> {
  late final MusicPlayerBloc _musicPlayerBloc;
  late final AudioPlayer _audioPlayer;
  PlayerState _audioPlayerState = PlayerState.stopped;
  Duration _audioPlayerPosition = Duration.zero;
  Duration _audioPlayerDuration = Duration.zero;
  late num _bpm;
  late int _playlistIndex;
  late int _shuffledIndex;
  late bool _isShuffle;
  late bool _isLoop;
  late bool _isBPMSync;
  late final theme = Theme.of(context);

  //TODO put these in the BLoC one day...
  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<Duration> _durationSubscription;
  late final StreamSubscription<PlayerState> _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
    _audioPlayer = _musicPlayerBloc.state.audioPlayer;
    _bpm = _musicPlayerBloc.state.bpm;
    _playlistIndex = _musicPlayerBloc.state.playlistIndex;
    _shuffledIndex = _musicPlayerBloc.state.shuffledIndex;
    _isShuffle = _musicPlayerBloc.state.isShuffle;
    _isLoop = _musicPlayerBloc.state.isLoop;
    _isBPMSync = _musicPlayerBloc.state.isBPMSync;

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
        if (_isLoop) {
          _musicPlayerBloc.add(const MusicPlayerLoop());
        } else {
          _musicPlayerBloc.add(const MusicPlayerPlayNext());
        }
      }
    });
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
  void dispose() {
    super.dispose();
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _playerStateSubscription.cancel();
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
        },
        child: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
            builder: (context, state) {
          final currentMusic = getCurrentMusic();
          return currentMusic == null
              ? const SizedBox.shrink()
              : Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primaryFixedDim),
                  ),
                  width: double.infinity,
                  height: 65,
                  child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const FullMusicPlayer()),
                        );
                      },
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! < 0) {
                          _musicPlayerBloc.add(const MusicPlayerPlayNext());
                        } else if (details.primaryVelocity! > 0) {
                          _musicPlayerBloc.add(const MusicPlayerPlayPrevious());
                        }
                      },
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity! > 0) {
                          _musicPlayerBloc.add(const MusicPlayerStop());
                        }
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Column(children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.memory(
                                      currentMusic.coverImage,
                                      width: 60,
                                      height: 45,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(
                                      height: 60,
                                      width: 150,
                                      child: ScrollingText(
                                        text: currentMusic.title,
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                  SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: _isBPMSync
                                            ? () {
                                                setState(() {
                                                  _bpm -= 1;
                                                });
                                                _musicPlayerBloc.add(
                                                    MusicPlayerSetBpm(_bpm));
                                              }
                                            : null,
                                        icon: const Icon(Icons.remove),
                                      )),
                                  Row(
                                      textBaseline: TextBaseline.alphabetic,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      children: [
                                        BlocListener<MusicPlayerBloc,
                                                MusicPlayerState>(
                                            listenWhen: (previous, current) =>
                                                previous.bpm != current.bpm,
                                            listener: (context, state) {
                                              setState(() {
                                                _bpm = state.bpm;
                                              });
                                            },
                                            child: Column(children: [
                                              Text(
                                                _bpm.round().toString(),
                                                style: TextStyle(
                                                    color: _isBPMSync
                                                        ? null
                                                        : Colors.grey[600]!),
                                              ),
                                              Text(
                                                "BPM",
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: _isBPMSync
                                                        ? null
                                                        : Colors.grey[600]!),
                                              )
                                            ]))
                                      ]),
                                  SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: _isBPMSync
                                            ? () {
                                                setState(() {
                                                  _bpm += 1;
                                                });
                                                _musicPlayerBloc.add(
                                                    MusicPlayerSetBpm(_bpm));
                                              }
                                            : null,
                                        icon: Icon(Icons.add,
                                            color: _isBPMSync
                                                ? null
                                                : Colors.grey[600]!)),
                                  ),
                                  SizedBox(
                                      width: 35,
                                      height: 35,
                                      child: _audioPlayerState ==
                                              PlayerState.playing
                                          ? IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () =>
                                                  _musicPlayerBloc.add(
                                                      const MusicPlayerPause()),
                                              icon: const Icon(Icons.pause))
                                          : IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                _musicPlayerBloc.add(
                                                    const MusicPlayerResume());
                                              },
                                              icon: const Icon(
                                                  Icons.play_arrow))),
                                ]),
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
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                width: double.infinity,
                                child: ProgressBar(
                                  progress: _audioPlayerPosition,
                                  total: _audioPlayerDuration,
                                  thumbRadius: 0,
                                  timeLabelTextStyle: const TextStyle(
                                    fontSize: 0,
                                  ),
                                  barHeight: 2,
                                  baseBarColor: theme.colorScheme.primary,
                                  progressBarColor:
                                      theme.colorScheme.inversePrimary,
                                ),
                              ),
                            ),
                          ]))));
        }));
  }
}
