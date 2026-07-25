import 'package:flutter/material.dart';

const double fontSize = 15;

ButtonStyle getMenuButtonStyle(BuildContext context) {
  final contentColor = _getColor(context);
  return ButtonStyle(
    shape: WidgetStateProperty.all<LinearBorder>(LinearBorder()),
    textStyle: WidgetStateProperty.all<TextStyle>(TextStyle(color: contentColor, fontSize: fontSize)),
    iconColor:  WidgetStateProperty.all<Color>(contentColor),
    iconSize:  WidgetStateProperty.all<double>(fontSize + 5)
  );

}

TextStyle getTextStyle(BuildContext context) {
  final contentColor = _getColor(context);
  return TextStyle(color: contentColor, fontSize: fontSize);
}

Color _getColor(BuildContext context) {
  final theme = Theme.of(context);
  return theme.colorScheme.onSecondaryContainer;
}
