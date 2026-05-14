import 'package:flutter/material.dart';

enum ModuleStatus { scaffolded, mock, needsCredentials }

class AppModule {
  const AppModule({
    required this.title,
    required this.route,
    required this.icon,
    required this.summary,
    required this.acceptance,
    this.status = ModuleStatus.scaffolded,
  });

  final String title;
  final String route;
  final IconData icon;
  final String summary;
  final String acceptance;
  final ModuleStatus status;
}
