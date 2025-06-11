import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'home.dart' show FeatureCardScreen;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late FlutterTts _flutterTts;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/recognation.json",
      "title": "WELCOME TO VISION",
      "description": "Your personal visual assistant for daily tasks",
    },
    {
      "image": "assets/search.json",
      "title": "OBJECT RECOGNITION",
      "description": "Hear clear descriptions of objects around you",
    },
    {
      "image": "assets/scan.json",
      "title": "TEXT READING",
      "description": "instant audio feedback from printed text",
    },
  ];

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _speakCurrentPage();
  }
  Future<void> _speakCurrentPage() async {
    final title = onboardingData[_currentIndex]["title"];
    final desc = onboardingData[_currentIndex]["description"];

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak("$title. $desc");
  }

  Future<void> _completeOnboarding() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FeatureCardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _speakCurrentPage();

              },
              itemBuilder: (context, index) {
                return OnboardingPage(
                  image: onboardingData[index]["image"]!,
                  title: onboardingData[index]["title"]!,
                  description: onboardingData[index]["description"]!,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(onboardingData.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 10,
                      width: _currentIndex == index ? 30 : 10,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? const Color(0xFF4178bf)
                            : const Color(0xff8e9598),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 40,),
                Padding(
                  padding: const EdgeInsets.only(bottom:30.0),
                  child: MaterialButton(
                      onPressed: () {
                        if (_currentIndex < onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      color: const Color(0xFF4178bf),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minWidth: 300,
                      height: 60,
                      child: Text(
                        "Next",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image, title, description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Lottie.asset(
             image,
            width: 250,
            height: 250,
            fit: BoxFit.cover,
            repeat: true,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 16, color: Color(0xFF696969)),
          ),
        ],
      ),
    );
  }
}
