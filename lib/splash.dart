import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'onboarding.dart';


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();

    _flutterTts = FlutterTts();
    _speakWelcomeMessage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      });
    });
  }

  Future<void> _speakWelcomeMessage() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(
      "Welcome to Smart Vision Features App",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              child: Image.asset(
                'assets/eye.png',
                width: 220,
                height: 220,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
