import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_generator/word_generator.dart';
import 'package:zonetwo/music_player/bloc/music_player_bloc.dart';

class TalkTestDialog extends StatelessWidget {
  const TalkTestDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final musicPlayerBloc = context.read<MusicPlayerBloc>();
    final bpm = musicPlayerBloc.state.bpm;
    return AlertDialog(
      title: const Text("Are you in Zone Two?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
              "Rate how it feels to say a few words like these out loud:"),
          const SizedBox(height: 10),
          Text(
            WordGenerator().randomSentence(5),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            onPressed: () {
              context.read<MusicPlayerBloc>().add(MusicPlayerSetBpm(bpm + 1));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Looks like you've got more in you!"),
                ),
              );
            },
            icon:
                Icon(Icons.sentiment_very_satisfied, color: Colors.green[700]),
            label: Text("Not even breaking a sweat!",
                style: TextStyle(color: Colors.green[700])),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("You're in Zone Two!"),
                ),
              );
            },
            icon:
                Icon(Icons.sentiment_satisfied, color: Colors.lightGreen[700]),
            label: Text("I can keep this up.",
                style: TextStyle(color: Colors.lightGreen[700])),
          ),
          TextButton.icon(
            onPressed: () {
              context.read<MusicPlayerBloc>().add(MusicPlayerSetBpm(bpm - 1));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Slow down a little, you can do it!"),
                ),
              );
            },
            icon: Icon(Icons.sentiment_neutral, color: Colors.yellow[800]),
            label: Text("Need to breathe hard after.",
                style: TextStyle(color: Colors.yellow[800])),
          ),
          TextButton.icon(
            onPressed: () {
              context.read<MusicPlayerBloc>().add(MusicPlayerSetBpm(bpm - 3));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("You're training too hard!"),
                ),
              );
            },
            icon:
                Icon(Icons.sentiment_very_dissatisfied, color: Colors.red[700]),
            label: Text("Please don't make me do this...",
                style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"))
      ],
    );
  }
}
