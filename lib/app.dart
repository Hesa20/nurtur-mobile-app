import 'package:flutter/material.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_theme.dart';
import 'package:nurtur_app_wppl_agile/features/auth/presentation/pages/login_page.dart';

class NurturApp extends StatelessWidget {
  const NurturApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nurtur',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
