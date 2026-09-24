import 'package:flutter/material.dart';

/// AppBar title that wraps onto a second line instead of running off the
/// screen (the default AppBar title is a single, ellipsised line).
class AppBarTitle extends StatelessWidget {
  const AppBarTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 3,
      softWrap: true,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.15),
    );
  }
}
