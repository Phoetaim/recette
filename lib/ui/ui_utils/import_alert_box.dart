import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recette/ui/ui_utils/styles.dart';

import '../../utils/commands.dart';

class ImportButton extends StatelessWidget {
  const ImportButton({super.key, required this.callback, this.isMenuButton = false});

  final Command1<void, String> callback;
  final bool isMenuButton;

  @override
  Widget build(BuildContext context) {
    if (isMenuButton) {
      return TextButton(
        style: getMenuButtonStyle(context),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertBox(callback: callback),
        ),
        child: Row(children: [Icon(importIcon), SizedBox(width: 8), Text('Importer', style: getTextStyle(context),)]),
      );
    }
    return TextButton(
      onPressed: () => showDialog(
        context: context,
        builder: (context) => AlertBox(callback: callback),
      ),
      child: Icon(importIcon),
    );
  }
}

class AlertBox extends StatefulWidget {
  const AlertBox({super.key, required this.callback});

  final Command1<void, String> callback;

  @override
  State<AlertBox> createState() => _AlertBoxState();
}

class _AlertBoxState extends State<AlertBox> {
  String base64ImportData = '';

  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
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
        );

  }
}

final importIcon = CupertinoIcons.arrow_down_left;
final exportIcon = CupertinoIcons.arrow_up_right;
