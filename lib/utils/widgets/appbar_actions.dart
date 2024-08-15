import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zonetwo/music_player/bloc/music_player_bloc.dart';

class AppBarActions {
  static List<Widget> getActions() {
    return <Widget>[
      const BPMSyncToggle(),
      const LoopToggle(),
      const ShuffleToggle(),
    ];
  }
}

class BPMSyncToggle extends StatefulWidget {
  const BPMSyncToggle({super.key});

  @override
  BPMSyncToggleState createState() => BPMSyncToggleState();
}

class BPMSyncToggleState extends State<BPMSyncToggle> {
  late final MusicPlayerBloc _musicPlayerBloc;
  late bool _isBPMSync;

  @override
  void initState() {
    super.initState();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
    _isBPMSync = _musicPlayerBloc.state.isBPMSync;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerBloc, MusicPlayerState>(
      listenWhen: (previous, current) =>
          previous.isBPMSync != current.isBPMSync,
      listener: (context, state) =>
          setState(() => _isBPMSync = state.isBPMSync),
      child: IconButton(
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
        onPressed: () => _musicPlayerBloc.add(const MusicPlayerToggleBPMSync()),
      ),
    );
  }
}

class LoopToggle extends StatefulWidget {
  const LoopToggle({super.key});

  @override
  State<StatefulWidget> createState() => LoopToggleState();
}

class LoopToggleState extends State<LoopToggle> {
  late final MusicPlayerBloc _musicPlayerBloc;
  late bool _isLoop;

  @override
  void initState() {
    super.initState();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
    _isLoop = _musicPlayerBloc.state.isLoop;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerBloc, MusicPlayerState>(
      listenWhen: (previous, current) => previous.isLoop != current.isLoop,
      listener: (context, state) => setState(() => _isLoop = state.isLoop),
      child: IconButton(
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
        onPressed: () => _musicPlayerBloc.add(const MusicPlayerToggleLoop()),
      ),
    );
  }
}

class ShuffleToggle extends StatefulWidget {
  const ShuffleToggle({super.key});

  @override
  State<StatefulWidget> createState() => ShuffleToggleState();
}

class ShuffleToggleState extends State<ShuffleToggle> {
  late final MusicPlayerBloc _musicPlayerBloc;
  late bool _isShuffle;

  @override
  void initState() {
    super.initState();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
    _isShuffle = _musicPlayerBloc.state.isShuffle;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerBloc, MusicPlayerState>(
        listenWhen: (previous, current) =>
            previous.isShuffle != current.isShuffle,
        listener: (context, state) =>
            setState(() => _isShuffle = state.isShuffle),
        child: IconButton(
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
            onPressed: () =>
                _musicPlayerBloc.add(const MusicPlayerToggleShuffle())));
  }
}
