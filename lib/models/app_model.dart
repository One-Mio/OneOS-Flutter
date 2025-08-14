import 'package:flutter/material.dart';

class AppModel {
  final String name;
  final IconData icon;
  final Color color;
  final Function()? onTap;

  AppModel({
    required this.name,
    required this.icon,
    this.color = Colors.blue,
    this.onTap,
  });
}