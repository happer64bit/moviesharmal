import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 800), () {
      GoRouter.of(context).pushReplacement("/");
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            RichText(
              text: TextSpan(
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 70,
                  color: brightness == Brightness.light ? Colors.black : Colors.white,
                ),
                children: const [
                  TextSpan(
                    text: "M",
                    style: TextStyle(
                      fontSize: 100
                    )
                  ),
                  WidgetSpan(
                    child: Icon(
                      Icons.search,
                      size: 70,
                    )
                  ),
                  TextSpan(
                    text: "vie"
                  )
                ]
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(
                bottom: 20
              ),
              child: Text(
                "Made By Wint Khant Lin With ❤️",
                style: TextStyle(
                  fontSize: 18
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}