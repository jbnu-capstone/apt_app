import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/screens/home/_home.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/score_view/pdf_viewer.dart';

void removeHive() {}

Future<void> hiveInit() async {
  await Hive.initFlutter();
  // Hive.registerAdapter(SomeAdapter());
}

void main() async {
  await hiveInit();
  runApp(ProviderScope(child: MyApp()));
}

final themeSeedColorProvider = StateProvider<Color>((ref) => Colors.deepPurple);

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  /*---------go_router---------*/
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/pdf-viewer',
        builder: (context, state) {
          final pdfFile = state.extra as File;
          return PdfViewer(pdfFile: pdfFile);
        },
      ),
    ],
  );

  /*---------build---------*/
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSeedColor = ref.watch(themeSeedColorProvider);

    return MaterialApp.router(
      title: 'APT: Auto Page Turner',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: themeSeedColor,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: themeSeedColor,
        ),
        useMaterial3: true,
      ),
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
    );
  }
}
