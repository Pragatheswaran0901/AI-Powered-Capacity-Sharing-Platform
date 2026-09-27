import 'package:flutter/material.dart';
import 'package:machhunt/core/theme/app_theme.dart';
import 'package:machhunt/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MachHuntApp());
}

class MachHuntApp extends StatelessWidget {
  const MachHuntApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mach-Hunt — MSME Capacity Sharing Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
