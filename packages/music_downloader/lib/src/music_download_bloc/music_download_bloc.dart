import 'package:bloc/bloc.dart';
import 'package:music_downloader/music_downloader.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

class MusicDownloadBloc extends Bloc<MusicDownloadEvent, MusicDownloadState> {
  MusicDownloadBloc({required this.musicRepository})
      : super(MusicDownloadStateIdle()) {
    on<DownloadClicked>(_onDownloadClicked, transformer: droppable());
  }

  final MusicRepository musicRepository;

  Future<void> _onDownloadClicked(
    DownloadClicked event,
    Emitter<MusicDownloadState> emit,
  ) async {
    final downloadLink = event.link;

    if (downloadLink.isEmpty) return emit(MusicDownloadStateIdle());

    emit(MusicDownloadStateLoading(0));

    try {
      final musicInfo = await musicRepository
          .downloadByYoutubeLink(downloadLink, (actualBytes, int totalBytes) {
        emit(MusicDownloadStateLoading((actualBytes / totalBytes * 100)));
      });
      emit(MusicDownloadStateSuccess(musicInfo));
    } catch (error) {
      emit(
        error is ApiError
            ? MusicDownloadStateError(error.message)
            : const MusicDownloadStateError('something went wrong'),
      );
    }
  }
}
