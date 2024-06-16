import 'package:bloc/bloc.dart';
import 'package:download_repository/download_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:music_repository/music_repository.dart';

import '../entities/music_entity.dart';

part 'music_download_event.dart';
part 'music_download_state.dart';

class MusicDownloadBloc extends Bloc<MusicDownloadEvent, MusicDownloadState> {
  MusicDownloadBloc(
      {required this.downloadRepository, required this.musicRepository})
      : super(MusicDownloadStateIdle()) {
    on<DownloadClicked>(_onDownloadClicked, transformer: droppable());
  }

  final DownloadRepository downloadRepository;
  final MusicRepository musicRepository;

  Future<void> _onDownloadClicked(
    DownloadClicked event,
    Emitter<MusicDownloadState> emit,
  ) async {
    final downloadLink = event.link;

    if (downloadLink.isEmpty) return emit(MusicDownloadStateIdle());

    emit(MusicDownloadStateLoading(0));

    try {
      final musicDownloadInfo = await downloadRepository
          .downloadByYoutubeLink(downloadLink, (actualBytes, int totalBytes) {
        emit(MusicDownloadStateLoading((actualBytes / totalBytes * 100)));
      });
      final musicData = await musicRepository.addMusicData(MusicData(
          id: "",
          title: musicDownloadInfo.title,
          savePath: musicDownloadInfo.savePath,
          bpm: musicDownloadInfo.bpm));
      final allMusics = await musicRepository.getAllMusicData();
      debugPrint(allMusics.toString());
      emit(MusicDownloadStateSuccess(MusicEntity.fromData(musicData)));
    } catch (error) {
      debugPrint(error.toString());
      emit(
        error is ApiError
            ? MusicDownloadStateError(error.message)
            : const MusicDownloadStateError('something went wrong'),
      );
    }
  }
}
