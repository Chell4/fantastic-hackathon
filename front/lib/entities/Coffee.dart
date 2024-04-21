import 'package:flutter/material.dart';

class Coffee extends StatefulWidget {
  final String id;
  final double width;

  const Coffee({super.key, required this.id, required this.width});

  @override
  State<Coffee> createState() => _CoffeeState();
}

class _CoffeeState extends State<Coffee> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
