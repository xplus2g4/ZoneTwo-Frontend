import 'package:flutter/material.dart';

class BackendIpDialog extends StatefulWidget {
  const BackendIpDialog(this.initialValue, {super.key});

  final String initialValue;

  @override
  State<BackendIpDialog> createState() => _BackendIpDialogState();
}

class _BackendIpDialogState extends State<BackendIpDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.initialValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _textController,
          keyboardType: TextInputType.url,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => {
            Navigator.pop(context, _textController.text),
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
