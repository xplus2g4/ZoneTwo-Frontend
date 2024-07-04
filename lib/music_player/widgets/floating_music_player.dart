import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zonetwo/music_player/music_player.dart';

class FloatingMusicPlayer extends StatefulWidget {
  const FloatingMusicPlayer({super.key});

  @override
  State<FloatingMusicPlayer> createState() => _FloatingMusicPlayerState();
}

class _FloatingMusicPlayerState extends State<FloatingMusicPlayer> {
  late final AudioPlayer _audioPlayer;
  late final MusicPlayerBloc _musicPlayerBloc;
  late num _bpm;

  @override
  void initState() {
    super.initState();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
    _bpm = _musicPlayerBloc.state.bpm;
    _audioPlayer = AudioPlayer();
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
            previous.status != current.status || current.bpm != previous.bpm,
        listener: (context, state) {
          setState(() {
            _bpm = state.bpm;
          });
          switch (state.status) {
            case MusicPlayerStatus.idle:
              break;
            case MusicPlayerStatus.paused:
              _audioPlayer.pause();
              break;
            case MusicPlayerStatus.playing:
              if (_audioPlayer.state != PlayerState.playing) {
                _audioPlayer.resume();
              }
              if (state.currentIndex != -1) {
                final currMusic = state.musicQueue[state.currentIndex];
                _audioPlayer.setSourceDeviceFile(currMusic.savePath);
                _audioPlayer.setPlaybackRate(
                    state.bpm / state.musicQueue[state.currentIndex].bpm);
              }
              break;
            case MusicPlayerStatus.insertNext:
              if (state.currentIndex != -1) {
                final currMusic = state.musicQueue[state.currentIndex];
                if (_audioPlayer.state == PlayerState.playing) {
                  _audioPlayer.stop();
                }
                _audioPlayer.setSourceDeviceFile(currMusic.savePath).then(
                    (_) => _musicPlayerBloc.add(const MusicPlayerResume()));
              }
              break;
          }
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
                  child: Padding(
                      padding:
                          const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.grey[800],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.memory(
                                  currMusic.coverImage,
                                  width: 62,
                                  height: 62,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                child: Text(currMusic.title, maxLines: 1),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _bpm -= 1;
                                    });
                                    _musicPlayerBloc
                                        .add(MusicPlayerSetBpm(_bpm));
                                  },
                                  icon: const Icon(Icons.remove)),
                              Text(_bpm.round().toString()),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _bpm += 1;
                                    });
                                    _musicPlayerBloc
                                        .add(MusicPlayerSetBpm(_bpm));
                                  },
                                  icon: const Icon(Icons.add)),
                              if (state.status == MusicPlayerStatus.playing)
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
                          ))));
        }));
  }
}
