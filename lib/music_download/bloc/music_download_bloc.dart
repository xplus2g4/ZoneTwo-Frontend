import 'package:bloc/bloc.dart';
import 'package:download_repository/download_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:music_repository/music_repository.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

part 'music_download_event.dart';
part 'music_download_state.dart';

class MusicDownloadBloc extends Bloc<MusicDownloadEvent, MusicDownloadState> {
  MusicDownloadBloc(
      {required this.downloadRepository, required this.musicRepository})
      : super(const MusicDownloadState()) {
    on<DownloadClicked>(_onDownloadClicked);
    on<LinkSharedEvent>(_onLinkSharedEvent);
    on<RetryDownloadEvent>(_onRetryDownloadEvent);
  }

  final DownloadRepository downloadRepository;
  final MusicRepository musicRepository;

  String? validateLink(String link) {
    final desktopLink =
        RegExp(r"^https://(?:www\.)?youtube\.com/watch\?v=([^&]+)")
            .firstMatch(link)
            ?.group(1);
    if (desktopLink != null) return desktopLink;
    final mobileLink =
        RegExp(r"^https://youtu\.be/([^?]+)").firstMatch(link)?.group(1);
    if (mobileLink != null) return mobileLink;
    return null;
  }

  ValueChanged<String> _onFilenameConfirmed(
      Emitter<MusicDownloadState> emit, String videoIdentifier) {
    return (String filename) {
      emit(state.copyWith(
        progress: () => state.progress
            .map((p) =>
                p.url == videoIdentifier ? p.updateFilename(filename) : p)
            .toList(),
      ));
    };
  }

  Future<void> _downloadMusic(
    Emitter<MusicDownloadState> emit,
    String videoIdentifier,
  ) async {
    final downloadLink = 'https://www.youtube.com/watch?v=$videoIdentifier';

    try {
      final musicDownloadInfo = await downloadRepository.downloadByYoutubeLink(
        downloadLink,
        progressCallback: (actualBytes, int totalBytes) {
          emit(state.copyWith(
            progress: () => state.progress
                .map((p) => p.url == videoIdentifier
                    ? p.updateProgress(actualBytes / totalBytes)
                    : p)
                .toList(),
          ));
        },
        onFilenameCallback: _onFilenameConfirmed(emit, videoIdentifier),
      );
      await musicRepository.addMusicData(MusicData.newData(
          title: musicDownloadInfo.title,
          savePath: musicDownloadInfo.savePath,
          bpm: musicDownloadInfo.bpm,
          coverImage: musicDownloadInfo.coverImage));
    } catch (error) {
      final errorMessage =
          error is ApiError ? error.message : 'something went wrong';
      emit(state.copyWith(
        progress: () => state.progress
            .map((p) => p.url == videoIdentifier ? p.onError(errorMessage) : p)
            .toList(),
      ));
    }
  }

  Future<void> _onDownloadClicked(
    DownloadClicked event,
    Emitter<MusicDownloadState> emit,
  ) async {
    if (event.link.isEmpty) {
      emit(state.copyWith(linkValidationError: () => 'link cannot be empty'));
      return;
    }
    final videoIdentifier = validateLink(event.link);
    if (videoIdentifier == null) {
      emit(state.copyWith(linkValidationError: () => 'invalid link'));
      return;
    }

    emit(state.copyWith(
      linkValidationError: () => '',
      progress: () =>
          [MusicDownloadProgress(videoIdentifier), ...state.progress],
    ));

    await _downloadMusic(emit, videoIdentifier);
  }

  Future<void> _onLinkSharedEvent(
    LinkSharedEvent event,
    Emitter<MusicDownloadState> emit,
  ) async {
    final videoIdentifier = validateLink(event.sharedMediaFile.path);
    if (videoIdentifier == null) {
      emit(state.copyWith(linkValidationError: () => 'invalid link'));
      return;
    }

    emit(state.copyWith(
      linkValidationError: () => '',
      progress: () =>
          [MusicDownloadProgress(videoIdentifier), ...state.progress],
    ));

    await _downloadMusic(emit, videoIdentifier);
  }

  Future<void> _onRetryDownloadEvent(
    RetryDownloadEvent event,
    Emitter<MusicDownloadState> emit,
  ) async {
    emit(state.copyWith(
      progress: () => state.progress
          .map((p) => p.url == event.videoIdentifier
              ? MusicDownloadProgress(
                  event.videoIdentifier,
                  filename: p.filename,
                )
              : p)
          .toList(),
    ));
    await _downloadMusic(emit, event.videoIdentifier);
  }
}
