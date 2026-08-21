import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recette/ui/ui_utils/styles.dart';

import '../../utils/commands.dart';

class ImportButton extends StatelessWidget {
  const ImportButton({super.key, required this.callback, this.isMenuButton = false});

  final Command0<void> callback;
  final bool isMenuButton;

  @override
  Widget build(BuildContext context) {
    if (isMenuButton) {
      return TextButton(
        style: getMenuButtonStyle(context),
        onPressed: callback.execute,
        child: Row(children: [Icon(importIcon), SizedBox(width: 8), Text('Importer', style: getTextStyle(context),)]),
      );
    }
    return TextButton(
      onPressed: callback.execute,
      child: Icon(importIcon),
    );
  }
}


final importIcon = CupertinoIcons.arrow_down_left;
final exportIcon = CupertinoIcons.arrow_up_right;
