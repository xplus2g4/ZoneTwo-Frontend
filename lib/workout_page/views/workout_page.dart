import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'package:vibration/vibration.dart';
import 'package:zonetwo/music_overview/entities/music_entity.dart';
import 'package:zonetwo/music_player/music_player.dart';
import 'package:zonetwo/music_player/widgets/scrolling_text.dart';
import 'package:zonetwo/routes.dart';
import 'package:zonetwo/workout_overview/entities/workout_point.dart';
import 'package:zonetwo/workout_page/bloc/workout_page_bloc.dart';
import 'package:zonetwo/workout_page/widgets/select_playlist_bottom_sheet.dart';

class WorkoutPageArguments {
  WorkoutPageArguments({required this.datetime});

  final DateTime datetime;
}

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({required this.datetime, super.key});

  final DateTime datetime;

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  int _countdown = 10;
  bool _isCountdownOver = false;
  late final Timer _countdownTimer;

  bool _serviceEnabled = false;
  bool _isCheckingLocation = false;
  LocationPermission _permission = LocationPermission.denied;
  late final StreamSubscription<Position> _locationStreamSubscription;
  late Position _location;
  late Position _checkpointLocation;

  late final WorkoutPageBloc _workoutPageBloc;
  late final Stopwatch _stopwatch;
  bool _isRunning = false;
  Duration _duration = Duration.zero;
  double _distance = 0;
  String _pace = '-';
  late final Timer _workoutTimer;

  late final MusicPlayerBloc _musicPlayerBloc;
  PlayerState _audioPlayerState = PlayerState.stopped;
  Duration _audioPlayerPosition = Duration.zero;
  Duration _audioPlayerDuration = Duration.zero;
  late num _bpm;
  late int _playlistIndex;
  late int _shuffledIndex;
  late bool _isShuffle;
  late bool _isLoop;

  Future<void> _checkLocationService() async {
    setState(() {
      _isCheckingLocation = true;
    });

    bool newServiceEnabled;
    LocationPermission newPermission;

    newServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!newServiceEnabled) {
      await Location().requestService();
    }

    newPermission = await Geolocator.checkPermission();
    if (!(newPermission == LocationPermission.always ||
        newPermission == LocationPermission.whileInUse)) {
      newPermission = await Geolocator.requestPermission();
    }
    setState(() {
      _isCheckingLocation = false;
      _serviceEnabled = newServiceEnabled;
      _permission = newPermission;
    });
  }

  @override
  void initState() {
    super.initState();
    _workoutPageBloc = context.read<WorkoutPageBloc>();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();

    _stopwatch = _workoutPageBloc.state.stopwatch;
    _isRunning = _workoutPageBloc.state.isRunning;
    _duration = _workoutPageBloc.state.duration;

    _checkLocationService();

    _checkpointLocation = _location = Position(
        latitude: 0,
        longitude: 0,
        accuracy: 0,
        altitude: 0,
        speed: 0,
        speedAccuracy: 0,
        heading: 0,
        timestamp: DateTime.now(),
        altitudeAccuracy: 0,
        headingAccuracy: 0);
    

    Geolocator.getCurrentPosition().then((value) {
      _location = value;
      _checkpointLocation = value;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_countdown == 0) {
        setState(() {
          _isCountdownOver = true;
          _isRunning = true;
        });
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator != null && hasVibrator) {
          Vibration.vibrate();
        }
        timer.cancel();
        _workoutPageBloc.add(const WorkoutPageStart());
      } else {
        if (!_isCheckingLocation) {
          setState(() {
            _countdown -= 1;
          });
        }
      }
    });

    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isCountdownOver && _isRunning) {
        setState(() {
          _duration = _stopwatch.elapsed;
        });
        final delta = Geolocator.distanceBetween(
                _checkpointLocation.latitude,
                _checkpointLocation.longitude,
                _location.latitude,
                _location.longitude) /
            1000;
        final timeDifference =
            _location.timestamp.difference(_checkpointLocation.timestamp);
        if (timeDifference.inMilliseconds == 0) return;
        setState(() {
          _distance += delta;
          _pace = paceBetween(delta, timeDifference);
          _checkpointLocation = _location;
        });
        _workoutPageBloc.add(WorkoutPageDurationChanged(_duration));
      }
    });
   
    _locationStreamSubscription =
        Geolocator.getPositionStream().listen((position) {
      if (_isCountdownOver && _isRunning) {
        setState(() {
          _location = position;
        });
      }
    });

    _bpm = _musicPlayerBloc.state.bpm;
    _playlistIndex = _musicPlayerBloc.state.playlistIndex;
    _shuffledIndex = _musicPlayerBloc.state.shuffledIndex;
    _isShuffle = _musicPlayerBloc.state.isShuffle;
    _isLoop = _musicPlayerBloc.state.isLoop;

    _audioPlayerState = _musicPlayerBloc.state.audioPlayerState;
    _audioPlayerPosition = _musicPlayerBloc.state.audioPlayerPosition;
    _audioPlayerDuration = _musicPlayerBloc.state.audioPlayerDuration;
  }

  @override
  void dispose() {
    super.dispose();
    if (_isCountdownOver) {
      _workoutPageBloc.add(WorkoutPageSave(
        widget.datetime,
        _duration,
        _distance,
      ));
    }
    _workoutPageBloc.add(const WorkoutPageStop());
    _countdownTimer.cancel();
    _workoutTimer.cancel();
    _locationStreamSubscription.cancel();
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

  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
    return "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  String paceBetween(double delta, Duration duration) {
    double pace = duration.inMilliseconds / 1000.0 / delta;
    int minutes = pace ~/ 60;
    int seconds = (pace % 60).round();
    if (minutes > 20) return "-";
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}/km';
  }

  void launchConfirmationDialog() => showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('End workout?'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  context.pop();
                },
              ),
              TextButton(
                child: const Text('Quit', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  context.pop();
                  context.go(workoutOverviewPath);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Workout saved!')));
                },
              ),
            ],
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            if (_isCountdownOver) {
              _workoutPageBloc
                  .add(WorkoutPageSave(widget.datetime, _duration, _distance));
            }
            _workoutPageBloc.add(const WorkoutPageStop());
            return;
          }
          launchConfirmationDialog();
        },
        child: Scaffold(
          //neat trick to hide the appbar
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).padding.top),
            child: SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: BlocListener<WorkoutPageBloc, WorkoutPageState>(
                    listenWhen: (previous, current) =>
                        previous.duration != current.duration ||
                        previous.isRunning != current.isRunning,
                    listener: (context, state) {
                      setState(() {
                        _duration = state.duration;
                        _isRunning = state.isRunning;
                      });
                    },
                    child: Column(
                      children: [
                        if (!_isCountdownOver)
                          Text(
                            'Starting in $_countdown',
                            style: const TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold),
                          )
                        else
                          Text(
                            formatDuration(_duration),
                            style: TextStyle(
                                color:
                                    _isRunning ? Colors.white : Colors.white24,
                                fontSize: 48,
                                fontWeight: FontWeight.bold),
                          ),
                        const SizedBox(height: 12),
                        IntrinsicHeight(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Distance',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 12,
                                            shadows: <Shadow>[
                                              Shadow(
                                                offset: Offset(1.0, 1.0),
                                                color: Colors.black45,
                                                blurRadius: 3.0,
                                              ),
                                            ],
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${_distance.toStringAsFixed(2)}km',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: _isRunning
                                                ? Colors.white
                                                : Colors.white24,
                                            fontSize: 32,
                                            shadows: const <Shadow>[
                                              Shadow(
                                                offset: Offset(1.0, 1.0),
                                                color: Colors.black45,
                                                blurRadius: 3.0,
                                              ),
                                            ],
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )),
                              const VerticalDivider(
                                color: Colors.white60,
                              ),
                              Expanded(
                                  child: Column(
                                children: [
                                  const Text(
                                    'Pace',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(1.0, 1.0),
                                            color: Colors.black45,
                                            blurRadius: 3.0,
                                          ),
                                        ],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _pace,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: _isRunning
                                            ? Colors.white
                                            : Colors.white24,
                                        fontSize: 32,
                                        shadows: const <Shadow>[
                                          Shadow(
                                            offset: Offset(1.0, 1.0),
                                            color: Colors.black45,
                                            blurRadius: 3.0,
                                          ),
                                        ],
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                            ])),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: MultiBlocListener(
                      listeners: [
                        BlocListener<MusicPlayerBloc, MusicPlayerState>(
                          listenWhen: (previous, current) =>
                              previous.playlistIndex != current.playlistIndex ||
                              previous.shuffledIndex != current.shuffledIndex,
                          listener: (context, state) {
                            setState(() {
                              _playlistIndex = state.playlistIndex;
                              _shuffledIndex = state.shuffledIndex;
                            });
                          },
                        ),
                        //you have to drop one of these listeners for async
                        //queueing methods
                        BlocListener<MusicPlayerBloc, MusicPlayerState>(
                            listenWhen: (previous, current) =>
                                previous.playlistQueue != current.playlistQueue,
                            listener: (context, state) {
                              _musicPlayerBloc
                                  .add(const MusicPlayerPlayAtIndex(0));
                            })
                      ],
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: getCurrentMusic() == null
                                  ? const Icon(Icons.music_note)
                                  : Image.memory(
                                      getCurrentMusic()!.coverImage,
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 300,
                              height: 60,
                              child: ScrollingText(
                                  text: getCurrentMusic()?.title ??
                                      'No music playing',
                                  textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
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
                                      baseBarColor: Colors.white12,
                                      progressBarColor: Colors.white54,
                                    ))),
                          ])),
                ),
              ),
              Expanded(
                flex: 3,
                child: IntrinsicHeight(
                  child: Container(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 1,
                          child:
                              BlocListener<MusicPlayerBloc, MusicPlayerState>(
                          listenWhen: (previous, current) =>
                              previous.audioPlayerState !=
                                  current.audioPlayerState ||
                              previous.isLoop != current.isLoop ||
                              previous.isShuffle != current.isShuffle,
                          listener: (context, state) {
                            setState(() {
                              _audioPlayerState = state.audioPlayerState;
                              _isLoop = state.isLoop;
                              _isShuffle = state.isShuffle;
                            });
                            },
                            child: Column(
                              children: [
                                const Text(
                                  'Music Controls',
                                  style: TextStyle(shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      color: Colors.black45,
                                      blurRadius: 3.0,
                                    )
                                  ], fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _musicPlayerBloc.add(
                                            const MusicPlayerPlayPrevious());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(16),
                                      ),
                                      child: const Icon(
                                        Icons.skip_previous,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_audioPlayerState ==
                                            PlayerState.playing) {
                                          _musicPlayerBloc
                                              .add(const MusicPlayerPause());
                                        } else {
                                          _musicPlayerBloc
                                              .add(const MusicPlayerResume());
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(16),
                                      ),
                                      child: Icon(
                                        _audioPlayerState == PlayerState.playing
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        size: 32,
                                        color: Colors.white,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _musicPlayerBloc
                                            .add(const MusicPlayerPlayNext());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(16),
                                      ),
                                      child: const Icon(
                                        Icons.skip_next,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 9),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _musicPlayerBloc
                                            .add(const MusicPlayerToggleLoop());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      child: Icon(
                                        Icons.loop,
                                        size: 24,
                                        color: _isLoop
                                            ? Colors.blue
                                            : Colors.white54,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _musicPlayerBloc.add(
                                            const MusicPlayerToggleShuffle());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      child: Icon(
                                        Icons.shuffle,
                                        size: 24,
                                        color: _isShuffle
                                            ? Colors.blue
                                            : Colors.white54,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) =>
                                                SelectPlaylistBottomSheet(
                                                    _musicPlayerBloc));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      child: const Icon(
                                        Icons.list,
                                        size: 24,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Column(children: [
                              const Text(
                                'Workout Controls',
                                style: TextStyle(shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    color: Colors.black45,
                                    blurRadius: 3.0,
                                  )
                                ], fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    BlocListener<WorkoutPageBloc,
                                        WorkoutPageState>(
                                      listenWhen: (previous, current) =>
                                          previous.isRunning !=
                                          current.isRunning,
                                      listener: (context, state) {
                                        setState(() {
                                          _isRunning = state.isRunning;
                                        });
                                      },
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_isRunning) {
                                            _workoutPageBloc
                                                .add(const WorkoutPagePause());
                                          } else {
                                            _workoutPageBloc
                                                .add(const WorkoutPageResume());
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[800],
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(12),
                                        ),
                                        child: Icon(
                                          _isRunning
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          size: 36,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        launchConfirmationDialog();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[800],
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      child: const Icon(
                                        Icons.stop,
                                        size: 36,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ]),
                              const SizedBox(height: 8),
                              Container(
                                width: 200,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.black12),
                                child: Column(children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                            icon: const Icon(Icons.remove,
                                                color: Colors.white),
                                            iconSize: 24),
                                        BlocListener<MusicPlayerBloc,
                                                MusicPlayerState>(
                                            listenWhen: (previous, current) =>
                                                previous.bpm != current.bpm,
                                            listener: (context, state) {
                                              setState(() {
                                                _bpm = state.bpm;
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Text(
                                                  _bpm.round().toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      shadows: <Shadow>[
                                                        Shadow(
                                                          offset:
                                                              Offset(1.0, 1.0),
                                                          blurRadius: 3.0,
                                                          color: Colors.black,
                                                        ),
                                                      ],
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const Text("BPM",
                                                    style: TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 12)),
                                              ],
                                            )),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _bpm += 1;
                                            });
                                            _musicPlayerBloc
                                                .add(MusicPlayerSetBpm(_bpm));
                                          },
                                          icon: const Icon(Icons.add,
                                              color: Colors.white),
                                          iconSize: 24,
                                        )
                                      ]),
                                ]),
                              ),
                            ])),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
