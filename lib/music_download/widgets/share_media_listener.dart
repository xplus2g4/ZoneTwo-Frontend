import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

import '../bloc/music_download_bloc.dart';

class ShareMediaListener extends StatefulWidget {
  const ShareMediaListener({required this.child, super.key});

  final Widget child;

  @override
  State<ShareMediaListener> createState() => _ShareMediaListenerState();
}

class _ShareMediaListenerState extends State<ShareMediaListener> {
  late MusicDownloadBloc _musicDownloadBloc;
  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    _musicDownloadBloc = context.read<MusicDownloadBloc>();
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedFile> sharedMedia) {
      for (var media in sharedMedia) {
        if (media.value != null) {
          _musicDownloadBloc.add(DownloadClicked(link: media.value!));
        }
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    FlutterSharingIntent.instance
        .getInitialSharing()
        .then((List<SharedFile> sharedMedia) {
      for (var media in sharedMedia) {
        if (media.value != null) {
          _musicDownloadBloc.add(DownloadClicked(link: media.value!));
        }
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicDownloadBloc, MusicDownloadState>(
        listenWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        listener: (context, state) {
          final message = _getSnackerbarMessage(state);
          if (message != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar
              ..showSnackBar(SnackBar(
                content: Text(message),
              ));
          }
        },
        child: widget.child);
  }

  String? _getSnackerbarMessage(MusicDownloadState state) {
    return switch (state) {
      MusicDownloadStateSuccess() => "Downloaded!",
      MusicDownloadStateLoading() => "Downloading...",
      MusicDownloadStateError() => state.error,
      _ => null,
    };
  }
}
