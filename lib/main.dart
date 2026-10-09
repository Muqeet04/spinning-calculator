import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';

void main() {
  runApp(const ProviderScope(child: SpinLogicApp()));
}

class SpinLogicApp extends StatelessWidget {
  const SpinLogicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Spin Logic',
      theme: SpinLogicTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
