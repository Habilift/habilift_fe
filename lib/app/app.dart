import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class HabiLiftApp extends ConsumerWidget {
  const HabiLiftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'HabiLift',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
    );
  }
}
