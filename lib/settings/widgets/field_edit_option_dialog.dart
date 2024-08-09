import 'package:flutter/material.dart';

class FieldEditOptionDialog extends StatelessWidget {
  const FieldEditOptionDialog({
    required this.options,
    required this.currentOption,
    super.key,
  });

  final List<Enum> options;
  final Enum currentOption;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map((option) => RadioListTile<Enum>(
                  title: Text(option.name),
                  value: option,
                  groupValue: currentOption,
                  onChanged: (Enum? value) {
                    Navigator.pop(context, value);
                  },
                ))
            .toList(),
      ),
    );
  }
}
