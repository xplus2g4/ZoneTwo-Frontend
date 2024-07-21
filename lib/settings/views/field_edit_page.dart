import 'package:flutter/material.dart';

class FieldEditPageArguments {
  FieldEditPageArguments({
    required this.fieldName,
    required this.initialValue,
    required this.onConfirm,
  });

  final String fieldName;
  final String initialValue;
  final ValueChanged<String> onConfirm;
}

class FieldEditPage extends StatefulWidget {
  const FieldEditPage({
    required this.fieldName,
    required this.initialValue,
    required this.onConfirm,
    super.key,
  });

  final String fieldName;
  final String initialValue;
  final ValueChanged<String> onConfirm;

  @override
  State<FieldEditPage> createState() => _FieldEditPageState();
}

class _FieldEditPageState extends State<FieldEditPage> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.fieldName),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => widget.onConfirm(_controller.text),
            ),
          ],
        ),
        body: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ));
  }
}
