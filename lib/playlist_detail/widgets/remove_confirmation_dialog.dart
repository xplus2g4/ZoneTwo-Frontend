import 'package:flutter/material.dart';

class RemoveConfirmationDialog extends StatelessWidget {
  const RemoveConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm Remove"),
      content: const Text(
          "Selected music will be removed from playlist. Song files won't be deleted."),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Remove'),
        ),
      ],
    );
  }
}
