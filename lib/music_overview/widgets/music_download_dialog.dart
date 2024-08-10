// import 'package:download_repository/download_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:music_repository/music_repository.dart';
// import 'package:zonetwo/music_download/music_download.dart';

// class MusicDownloadDialog extends StatelessWidget {
//   MusicDownloadDialog({super.key}) : downloadRepository = DownloadRepository();

//   final DownloadRepository downloadRepository;
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => MusicDownloadBloc(
//         musicRepository: context.read<MusicRepository>(),
//         downloadRepository: downloadRepository,
//       ),
//       child: Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//         child: Container(
//           constraints: const BoxConstraints(maxHeight: 200),
//           child: Padding(
//             padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
//             child: _AddMusicDialog(),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AddMusicDialog extends StatefulWidget {
//   @override
//   State<_AddMusicDialog> createState() => __AddMusicDialogState();
// }

// class __AddMusicDialogState extends State<_AddMusicDialog> {
//   final _textController = TextEditingController();
//   late MusicDownloadBloc _musicDownloadBloc;

//   @override
//   void initState() {
//     super.initState();
//     _musicDownloadBloc = context.read<MusicDownloadBloc>();
//   }

//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         constraints: const BoxConstraints(maxHeight: 200),
//         child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextField(
//                   controller: _textController,
//                   autocorrect: false,
//                   onEditingComplete: _onConfirm,
//                   decoration: const InputDecoration(
//                     prefixIcon: Icon(Icons.search),
//                     border: InputBorder.none,
//                     hintText: 'Enter a YouTube link',
//                   )),
//               _DownloadList(),
//               BlocBuilder<MusicDownloadBloc, MusicDownloadState>(
//                 builder: (context, state) {
//                   switch (state) {
//                     case MusicDownloadStateLoading():
//                       return const SizedBox();
//                     default:
//                       return Column(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           mainAxisSize: MainAxisSize.max,
//                           children: [
//                             Row(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.of(context)
//                                           .pop(); // Close the dialog
//                                     },
//                                     child: const Text("Cancel"),
//                                   ),
//                                   TextButton(
//                                     onPressed: _onConfirm,
//                                     child: const Text("Submit"),
//                                   ),
//                                 ])
//                           ]);
//                   }
//                 },
//               ),
//             ]));
//   }

//   void _onConfirm() {
//     _musicDownloadBloc.add(DownloadClicked(link: _textController.text));
//     _textController.text = '';
//     FocusManager.instance.primaryFocus?.unfocus();
//   }
// }

// class _DownloadList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<MusicDownloadBloc, MusicDownloadState>(
//       builder: (context, state) {
//         return switch (state) {
//           MusicDownloadStateIdle() => const SizedBox(),
//           MusicDownloadStateLoading() => _DownloadLoading(
//               percentage: state.percentage,
//             ),
//           MusicDownloadStateError() => Text(state.error),
//           MusicDownloadStateSuccess() => _DownloadSuccess(music: state.music)
//         };
//       },
//     );
//   }
// }

// class _DownloadLoading extends StatelessWidget {
//   const _DownloadLoading({required this.percentage});

//   final String percentage;

//   @override
//   Widget build(BuildContext context) {
//     String percentageToString =
//         percentage == '0.00' ? 'Initializing...' : 'Progress: $percentage%';
//     return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//       const SizedBox(
//         height: 20.0,
//         width: 20.0,
//         child: Center(child: CircularProgressIndicator()),
//       ),
//       const SizedBox(width: 20),
//       Text(percentageToString),
//       const SizedBox(width: 10),
//     ]);
//   }
// }

// class _DownloadSuccess extends StatelessWidget {
//   const _DownloadSuccess({required this.music});

//   final MusicDownloadInfo music;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text("Success! BPM: ${music.bpm}",
//             style: TextStyle(color: Theme.of(context).colorScheme.primary)),
//       ],
//     );
//   }
// }
