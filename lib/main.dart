import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moviesharmal/screens/favourite_screen.dart';
import 'package:moviesharmal/screens/home_screen.dart';
import 'package:moviesharmal/utils/db.dart';
import 'util.dart';
import 'theme.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;

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
      initialLocation: "/",
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => const HomeScreen()
        ),
        GoRoute(
          path: "/favourite",
          builder: (context, state) => const FavouriteScreen()
        ),
      ]
    );

    return MaterialApp.router(
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      routerConfig: routerConfig,
      debugShowCheckedModeBanner: false,
    );
  }
}
