import 'package:flutter/material.dart';
import 'services/request_repository.dart';
import 'theme/app_theme.dart';
import 'widgets/responsive_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = RequestRepository();
  await repo.initialize();
  runApp(const EcoCollectApp());
}

class EcoCollectApp extends StatelessWidget {
  const EcoCollectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoCollect – E-Waste Collection Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ResponsiveLayout(),
    );
  }
}
