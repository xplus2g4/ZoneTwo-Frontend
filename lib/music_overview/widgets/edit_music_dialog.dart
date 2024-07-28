import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zonetwo/music_overview/music_overview.dart';

class EditMusicDialog extends StatefulWidget {
  const EditMusicDialog(this.music, {super.key});

  final MusicEntity music;

  @override
  State<EditMusicDialog> createState() => _EditMusicDialogState();
}

class _EditMusicDialogState extends State<EditMusicDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _bpmTextController;

  @override
  void initState() {
    super.initState();
    _bpmTextController =
        TextEditingController(text: widget.music.bpm.round().toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Music BPM"),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _bpmTextController,
          decoration: const InputDecoration(
            labelText: "BPM",
            counterText: "",
          ),
          maxLength: 3,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a BPM value.';
            }
            final bpm = int.tryParse(value);
            return (bpm != null && bpm <= 0)
                ? "BPM must be greater than 0"
                : null;
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => {
            if (_formKey.currentState!.validate())
              {
                Navigator.pop(context, _bpmTextController.text),
              }
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
