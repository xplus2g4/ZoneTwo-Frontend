import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zonetwo/music_player/music_player.dart';
import 'package:zonetwo/music_player/widgets/scrolling_text.dart';

class FloatingMusicPlayer extends StatefulWidget {
  const FloatingMusicPlayer({super.key});

  @override
  State<FloatingMusicPlayer> createState() => FloatingMusicPlayerState();
}

class FloatingMusicPlayerState extends State<FloatingMusicPlayer> {
  late final AudioPlayer _audioPlayer;
  late final MusicPlayerBloc _musicPlayerBloc;
  late num _bpm;

  @override
  void initState() {
    super.initState();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
    _bpm = _musicPlayerBloc.state.bpm;
    _audioPlayer = _musicPlayerBloc.state.audioPlayer;
    _audioPlayer.onPositionChanged.listen((event) {
      setState(() {});
    });
    _audioPlayer.onDurationChanged.listen((event) {
      setState(() {});
    });
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.completed) {
        // TODO: Implement next music
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerBloc, MusicPlayerState>(
        listenWhen: (previous, current) =>
            previous.audioPlayer.state != current.audioPlayer.state ||
            current.bpm != previous.bpm,
        listener: (context, state) {
          setState(() {
            _bpm = state.bpm;
          });
        },
        child: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
            builder: (context, state) {
          final currMusic = state.currentIndex == -1
              ? null
              : state.musicQueue[state.currentIndex];
          return currMusic == null
              ? const SizedBox.shrink()
              : SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const FullMusicPlayer()),
                        );
                        _musicPlayerBloc
                            .add(const MusicPlayerEnterFullscreen());
                      },
                  child: Padding(
                      padding:
                          const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      child: Container(
                          decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                          ),
                              child: Column(children: [
                                Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.memory(
                                  currMusic.coverImage,
                                      width: 60,
                                      height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                                    Container(
                                        height: 60,
                                        width: 100,
                                        child: ScrollingText(
                                          text: currMusic.title,
                                          textStyle:
                                              const TextStyle(fontSize: 16),
                                        )
                                  ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _bpm -= 1;
                                    });
                                    _musicPlayerBloc
                                        .add(MusicPlayerSetBpm(_bpm));
                                  },
                                      icon: const Icon(Icons.remove)),
                                  Row(
                                    textBaseline: TextBaseline.alphabetic,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    children: [
                                      Text(
                                        _bpm.round().toString(),
                                      ),
                                      const Text(
                                        " BPM",
                                        style: TextStyle(fontSize: 8),
                                      ),
                                    ],
                                  ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _bpm += 1;
                                    });
                                    _musicPlayerBloc
                                        .add(MusicPlayerSetBpm(_bpm));
                                  },
                                  icon: const Icon(Icons.add)),
                                  if (state.audioPlayer.state ==
                                      PlayerState.playing)
                                IconButton(
                                    onPressed: () => _musicPlayerBloc
                                        .add(const MusicPlayerPause()),
                                    icon: const Icon(Icons.pause))
                              else
                                IconButton(
                                    onPressed: () {
                                      _musicPlayerBloc
                                          .add(const MusicPlayerResume());
                                    },
                                    icon: const Icon(Icons.play_arrow)),
                            ],
                                ),
                                FutureBuilder(
                                  future: Future.wait([
                                    state.audioPlayer.getDuration(),
                                    state.audioPlayer.getCurrentPosition()
                                  ]),
                                  builder: (context, snapshot) => snapshot
                                              .hasData &&
                                          snapshot.data![0] != null &&
                                          snapshot.data![1] != null
                                      ? SizedBox(
                                          width: 360,
                                          child: ProgressBar(
                                            total: snapshot.data?[0] ??
                                                Duration.zero,
                                            progress: snapshot.data?[1] ??
                                                Duration.zero,
                                            thumbRadius: 0,
                                            timeLabelTextStyle: const TextStyle(
                                              fontSize: 0,
                                            ),
                                            barHeight: 1,
                                            baseBarColor: Colors.grey[800]!,
                                            progressBarColor: Colors.white54,
                                          ))
                                      : const SizedBox.shrink(),
                                )
                              ])))));
        }));
  }
}
