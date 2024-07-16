import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zonetwo/music_player/music_player.dart';
import 'package:image/image.dart' as img;
import 'package:zonetwo/music_player/widgets/scrolling_text.dart';

class FullMusicPlayer extends StatefulWidget {
  const FullMusicPlayer({super.key});

  @override
  State<FullMusicPlayer> createState() => _FullMusicPlayerState();
}

class _FullMusicPlayerState extends State<FullMusicPlayer> {
  late final MusicPlayerBloc _musicPlayerBloc;
  late final AudioPlayer _audioPlayer;
  late num _bpm;

  @override
  void initState() {
    super.initState();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
    _audioPlayer = _musicPlayerBloc.state.audioPlayer;
    _bpm = _musicPlayerBloc.state.bpm;
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

  Color getDominantColor(Uint8List bytes) {
    img.Pixel pixel =
        img.copyResize(img.decodeImage(bytes)!, height: 1).getPixel(0, 0);
    HSLColor hsl = HSLColor.fromColor(Color.fromRGBO(
        pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt(), pixel.a.toDouble()));
    return hsl
        .withSaturation(hsl.saturation < 0.8 ? hsl.saturation + 0.2 : 1.0)
        .withLightness(hsl.lightness < 0.8 ? hsl.lightness + 0.2 : 1.0)
        .toColor();
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
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        getDominantColor(currMusic.coverImage),
                        Colors.grey[900]!,
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
                                style: const TextStyle(fontSize: 24),
                              )),
                          const SizedBox(height: 16),
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
                                        total:
                                            snapshot.data?[0] ?? Duration.zero,
                                        progress:
                                            snapshot.data?[1] ?? Duration.zero,
                                        thumbRadius: 0,
                                        timeLabelPadding: 4,
                                        timeLabelLocation:
                                            TimeLabelLocation.below,
                                        timeLabelType: TimeLabelType.totalTime,
                                        timeLabelTextStyle: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                        onSeek: (duration) {
                                          state.audioPlayer.seek(duration);
                                        },
                                        barHeight: 8,
                                        baseBarColor: getDominantColor(
                                            currMusic.coverImage),
                                        progressBarColor: Colors.white54,
                                      ))
                                  : const CircularProgressIndicator()),
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
                          const Text("Adjusted to"),
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
                          const Text("BPM"),
                        ],
                      );
                    }),
                  ),
                );
        }));
  }
}

class PositionData {
  final Duration position;
  final Duration duration;

  PositionData(this.position, this.duration);
}
