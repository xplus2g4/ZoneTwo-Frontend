import 'package:bloc/bloc.dart';
import 'package:download_repository/download_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

part 'music_download_event.dart';
part 'music_download_state.dart';

class MusicDownloadBloc extends Bloc<MusicDownloadEvent, MusicDownloadState> {
  MusicDownloadBloc(
      {required this.downloadRepository, required this.musicRepository})
      : super(MusicDownloadStateIdle()) {
    on<DownloadClicked>(_onDownloadClicked, transformer: droppable());
    on<LinkSharedEvent>(_onLinkSharedEvent, transformer: droppable());
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

  Future<void> _onDownloadClicked(
    DownloadClicked event,
    Emitter<MusicDownloadState> emit,
  ) async {
    if (event.link.isEmpty) {
      emit(const MusicDownloadStateError('link is empty'));
      return;
    }
    final videoIdentifier = validateLink(event.link);
    if (videoIdentifier == null) {
      emit(const MusicDownloadStateError('invalid link'));
      return;
    }

    final downloadLink = 'https://www.youtube.com/watch?v=$videoIdentifier';
    emit(MusicDownloadStateLoading(0));

    try {
      final musicDownloadInfo = await downloadRepository.downloadByYoutubeLink(
        downloadLink,
        progressCallback: (actualBytes, int totalBytes) {
          emit(MusicDownloadStateLoading((actualBytes / totalBytes * 100)));
        },
      );
      await musicRepository.addMusicData(MusicData.newData(
          title: musicDownloadInfo.title,
          savePath: musicDownloadInfo.savePath,
          bpm: musicDownloadInfo.bpm,
          coverImage: musicDownloadInfo.coverImage));
      emit(MusicDownloadStateSuccess(musicDownloadInfo));
    } catch (error) {
      emit(
        error is ApiError
            ? MusicDownloadStateError(error.message)
            : const MusicDownloadStateError('something went wrong'),
      );
    }
  }

  Future<void> _onLinkSharedEvent(
    LinkSharedEvent event,
    Emitter<MusicDownloadState> emit,
  ) async {
    final videoIdentifier = validateLink(event.sharedMediaFile.path);
    if (videoIdentifier == null) {
      emit(const MusicDownloadStateError('invalid link'));
      return;
    }

    final downloadLink = 'https://www.youtube.com/watch?v=$videoIdentifier';
    emit(MusicDownloadStateLoading(0));

    try {
      final musicDownloadInfo = await downloadRepository.downloadByYoutubeLink(
        downloadLink,
      );
      await musicRepository.addMusicData(MusicData.newData(
          title: musicDownloadInfo.title,
          savePath: musicDownloadInfo.savePath,
          bpm: musicDownloadInfo.bpm,
          coverImage: musicDownloadInfo.coverImage));
      emit(MusicDownloadStateSuccess(musicDownloadInfo));
    } catch (error) {
      emit(
        error is ApiError
            ? MusicDownloadStateError(error.message)
            : const MusicDownloadStateError('something went wrong'),
      );
    }
  }
}
