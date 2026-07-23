import 'package:flutter/material.dart';

import '../../utils/commands.dart';

class ImportButton extends StatefulWidget {
  const ImportButton({super.key, required this.callback});

  final Command1<void, String> callback;

  @override
  State<ImportButton> createState() => _ImportButtonState();
}

class _ImportButtonState extends State<ImportButton> {
  String base64ImportData = '';

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: TextField(
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  base64ImportData = value;
                });
              },
              decoration: InputDecoration(hintText: 'Paste base64 exported data'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  widget.callback.execute(base64ImportData);
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.check),
              ),
            ],
          ),
        );
      },
      child: Icon(Icons.arrow_downward),
    );
  }
}
