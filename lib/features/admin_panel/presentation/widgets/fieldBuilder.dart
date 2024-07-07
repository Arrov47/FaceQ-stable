import 'package:flutter/material.dart';

List<Widget> fieldBuilder(
    String label, TextEditingController controller, BuildContext context) {
  return [
    Container(
      margin: const EdgeInsets.all(20.0),
      child: TextField(
        style: Theme.of(context).textTheme.labelLarge,
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    ),
  ];
}
