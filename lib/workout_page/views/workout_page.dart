import 'package:audioplayers/audioplayers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:workout_repository/workout_repository.dart';
import 'package:zonetwo/music_overview/entities/music_entity.dart';
import 'package:zonetwo/music_player/music_player.dart';
import 'package:zonetwo/music_player/widgets/scrolling_text.dart';
import 'package:zonetwo/routes.dart';
import 'package:zonetwo/utils/functions/format_duration.dart';
import 'package:zonetwo/workout_overview/entities/workout_point.dart';
import 'package:zonetwo/workout_page/bloc/workout_page_bloc.dart';
import 'package:zonetwo/workout_page/widgets/select_playlist_bottom_sheet.dart';
import 'package:zonetwo/workout_page/widgets/talk_test_dialog.dart';

class WorkoutPageArguments {
  WorkoutPageArguments({required this.datetime});

  final DateTime datetime;
}

class WorkoutPage extends StatelessWidget {
  final DateTime datetime;

  const WorkoutPage({required this.datetime, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => WorkoutPageBloc(
        workoutRepository: context.read<WorkoutRepository>(),
      ),
      child: WorkoutPageView(datetime: datetime),
    );
  }
}

class WorkoutPageView extends StatefulWidget {
  const WorkoutPageView({required this.datetime, super.key});

  final DateTime datetime;

  @override
  State<WorkoutPageView> createState() => WorkoutPageViewState();
}

class WorkoutPageViewState extends State<WorkoutPageView> {
  late final WorkoutPageBloc _workoutPageBloc;
  late int _countdown;
  late bool _isCountdownOver;
  late bool _isRunning;
  late Duration _duration = Duration.zero;
  late double _distance;
  late String _pace;
  late List<WorkoutPoint> _points;

  late final MusicPlayerBloc _musicPlayerBloc;
  PlayerState _audioPlayerState = PlayerState.stopped;
  Duration _audioPlayerPosition = Duration.zero;
  Duration _audioPlayerDuration = Duration.zero;
  late num _bpm;
  late String _playlistName;
  late int _playlistIndex;
  late int _shuffledIndex;
  late bool _isShuffle;
  late bool _isLoop;

  @override
  void initState() {
    super.initState();
    _workoutPageBloc = context.read<WorkoutPageBloc>();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();

    _isRunning = _workoutPageBloc.state.isRunning;
    _duration = _workoutPageBloc.state.duration;
    _distance = _workoutPageBloc.state.distance;
    _pace = _workoutPageBloc.state.pace;
    _points = _workoutPageBloc.state.points;
    _countdown = _workoutPageBloc.state.countdown;
    _isCountdownOver = _workoutPageBloc.state.isCountdownOver;

    _bpm = _musicPlayerBloc.state.bpm;
    _playlistName = _musicPlayerBloc.state.playlistName;
    _playlistIndex = _musicPlayerBloc.state.playlistIndex;
    _shuffledIndex = _musicPlayerBloc.state.shuffledIndex;
    _isShuffle = _musicPlayerBloc.state.isShuffle;
    _isLoop = _musicPlayerBloc.state.isLoop;

    _audioPlayerState = _musicPlayerBloc.state.audioPlayerState;
    _audioPlayerPosition = _musicPlayerBloc.state.audioPlayerPosition;
    _audioPlayerDuration = _musicPlayerBloc.state.audioPlayerDuration;

    _workoutPageBloc.add(const WorkoutPageInitializeLocation());
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    super.dispose();
    if (_isCountdownOver) {
      _workoutPageBloc.add(WorkoutPageSave(
        widget.datetime,
        _duration,
        _distance,
        _points
      ));
    }
    _workoutPageBloc.add(const WorkoutPageStop());
    WakelockPlus.disable();
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
                child: Text(_isCountdownOver ? 'Save and Exit' : 'Exit',
                    style: const TextStyle(color: Colors.red)),
                onPressed: () {
                  context.pop();
                  context.go(workoutOverviewPath);
                  if (_isCountdownOver) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Workout saved!')));
                  }
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
                  .add(WorkoutPageSave(
                  widget.datetime, _duration, _distance, _points));
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
                        previous.isRunning != current.isRunning ||
                        previous.countdown != current.countdown ||
                        previous.isCountdownOver != current.isCountdownOver,
                    listener: (context, state) {
                      setState(() {
                        _duration = state.duration;
                        _isRunning = state.isRunning;
                        _countdown = state.countdown;
                        _isCountdownOver = state.isCountdownOver;
                      });
                    },
                    child: Column(
                      children: [
                        const Text(
                            "Keep this screen on for the best workout experience",
                            style: TextStyle(
                                fontSize: 8,
                                fontStyle: FontStyle.italic)),  
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
                                color: Theme.of(context)
                                    .textTheme
                                    .headlineLarge!
                                    .color!
                                    .withOpacity(_isRunning ? 1 : 0.24),
                                fontSize: 48,
                                fontWeight: FontWeight.bold),
                          ),
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
                                            fontWeight: FontWeight.bold),
                                      ),
                                      BlocListener<WorkoutPageBloc,
                                          WorkoutPageState>(
                                        listenWhen: (previous, current) =>
                                            previous.distance !=
                                            current.distance,
                                        listener: (context, state) {
                                          setState(() {
                                            _distance = state.distance;
                                            _points = state.points;
                                          });
                                        },
                                        child: Text(
                                          '${_distance.toStringAsFixed(2)}km',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge!
                                                  .color!
                                                  .withOpacity(
                                                      _isRunning ? 1 : 0.24),
                                              fontSize: 33,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )),
                              const VerticalDivider(
                              ),
                              Expanded(
                                  child: Column(
                                children: [
                                  const Text(
                                    'Pace',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  BlocListener<WorkoutPageBloc,
                                      WorkoutPageState>(
                                    listenWhen: (previous, current) =>
                                        previous.pace != current.pace,
                                    listener: (context, state) {
                                      setState(() {
                                        _pace = state.pace;
                                      });
                                    },
                                    child: Text(
                                      _pace,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headlineLarge!
                                              .color!
                                              .withOpacity(
                                                  _isRunning ? 1 : 0.24),
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold),
                                    ),
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
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: 
                        BlocListener<MusicPlayerBloc, MusicPlayerState>(
                          listenWhen: (previous, current) =>
                              previous.playlistIndex != current.playlistIndex ||
                          previous.shuffledIndex != current.shuffledIndex ||
                          previous.playlistName != current.playlistName,
                          listener: (context, state) {
                            setState(() {
                              _playlistIndex = state.playlistIndex;
                              _shuffledIndex = state.shuffledIndex;
                          _playlistName = state.playlistName;
                            });
                      },
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Currently playing from ',
                                    style: TextStyle(
                                      fontSize: 9,
                                    )),
                                Text(_playlistName,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                            const SizedBox(height: 8),
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
                                      baseBarColor: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                      progressBarColor: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                    ))),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
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
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          shape: const CircleBorder(),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _bpm -= 5;
                                          });
                                          _musicPlayerBloc
                                              .add(MusicPlayerSetBpm(_bpm));
                                        },
                                        child: const Text(
                                          "-5",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _bpm -= 1;
                                            });
                                            _musicPlayerBloc
                                                .add(MusicPlayerSetBpm(_bpm));
                                          },
                                          icon: const Icon(
                                            Icons.remove,
                                          ),
                                          iconSize: 32),
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
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const Text("BPM",
                                                  style:
                                                      TextStyle(fontSize: 12)),
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
                                        icon: const Icon(
                                          Icons.add,
                                        ),
                                        iconSize: 32,
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          shape: const CircleBorder(),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _bpm += 5;
                                          });
                                          _musicPlayerBloc
                                              .add(MusicPlayerSetBpm(_bpm));
                                        },
                                        child: const Text(
                                          "+5",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ]),
                              ]),
                            ),
                          ])),
                ),
              ),
              Expanded(
                flex: 3,
                child: IntrinsicHeight(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                                const SizedBox(height: 8),
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
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                              TextButton.icon(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.blue),
                                  onPressed: () => showDialog(context: context, builder: (context) => const TalkTestDialog()),
                                  icon: const Icon(
                                    Icons.mic,
                                    color: Colors.white,
                                  ),
                                  label: const Text("Talk Test",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16))),
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
