import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moviesharmal/screens/home_screen.dart';
import 'util.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme = createTextTheme(context, "Rubik", "Rubik");

    MaterialTheme theme = MaterialTheme(textTheme);

    GoRouter routerConfig = GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => const HomeScreen()
        )
      ]
    );

    return MaterialApp.router(
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      routerConfig: routerConfig,
      debugShowCheckedModeBanner: false,
    );
  }
}
