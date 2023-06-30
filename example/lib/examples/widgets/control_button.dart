import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  const ControlButton({
    Key? key,
    required this.onPressed,
    required this.title
  }) : super(key: key);

  final VoidCallback onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(title, textAlign: TextAlign.center),
      ),
    );
  }
}
