import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:zonetwo/routes.dart';

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
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> sharedMedia) {
      for (var media in sharedMedia) {
        _musicDownloadBloc.add(LinkSharedEvent(media));
      }
    }, onError: (err) {});

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> sharedMedia) {
      for (var media in sharedMedia) {
        _musicDownloadBloc.add(LinkSharedEvent(media));
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
          previous.progress.length != current.progress.length,
      listener: (context, state) {
        if (GoRouterState.of(context).name != musicDownloadPath) {
          context.pushNamed(musicDownloadPath);
        }
        const message = "Downloading...";
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar
          ..showSnackBar(const SnackBar(
            content: Text(message),
          ));
      },
      child: widget.child,
    );
  }
}
