import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ManualInputBpmDialog extends StatefulWidget {
  const ManualInputBpmDialog(this.bpm, {super.key});

  final num bpm;

  @override
  State<ManualInputBpmDialog> createState() => _ManualInputBpmDialogState();
}

class _ManualInputBpmDialogState extends State<ManualInputBpmDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _bpmTextController;

  @override
  void initState() {
    super.initState();
    _bpmTextController = TextEditingController(text: widget.bpm.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("BPM"),
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
