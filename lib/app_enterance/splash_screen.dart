import 'dart:async';
import 'package:akshaya_flutter/app_enterance/language_screen.dart';
import 'package:akshaya_flutter/authentication/login_screen.dart';
import 'package:akshaya_flutter/common_utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isLogin = false;
  bool welcome = false;
  int langID = 0;

  @override
  void initState() {
    super.initState();
    loadData();
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        navigateToNextScreen();
      }
    });

    _animationController.forward();
  }

  void navigateToNextScreen() {
    if (isLogin) {
      // Navigate to home screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    //  context.go(Routes.homeScreen.path);
    } else {
      if (welcome) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
   //     context.go(Routes.loginScreen.path);
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LanguageScreen(),
          ),
        );
       // context.go(Routes.languageScreen.path);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context)
              .size
              .height, // Set container height to the screen height
          child: Stack(
            children: [
              // Background Image
              Image.asset(
                'assets/images/appbg.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              // Background Color with Opacity
              Container(
                color: const Color(0x8D000000), // Background color with opacity
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (BuildContext context, Widget? child) {
                        return Transform.scale(
                          scale: _animation.value,
                          child: Image.asset(
                            'assets/images/ic_logo.png',
                            width: 200,
                            height: 200,
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                        height: 16), // Add spacing between logo and text
                    // Typewriter Text
                    const TypewriterText(
                      text: "3F Oil Palm",
                      color: Color(0xFFCE0E2D),
                    ),
                    // Add spacing between the two lines
                    const TypewriterText(
                      text: "Sowing for a Better Future",
                      color: Color(0xFFe86100),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLogin = prefs.getBool(Constants.isLogin) ?? false;
      welcome = prefs.getBool(Constants.welcome) ?? false;
      langID = prefs.getInt("lang") ?? 0;
    });
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final Color color;

  const TypewriterText({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  _TypewriterTextState createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = ""; // Initial empty text
  int _index = 0; // Index for tracking characters

  @override
  void initState() {
    super.initState();
    // Start the typewriter animation
    _startTypewriterAnimation();
  }

  void _startTypewriterAnimation() {
    const Duration duration = Duration(milliseconds: 100);

    Timer.periodic(duration, (Timer timer) {
      if (_index < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_index];
          _index++;
        });
      } else {
        // Text animation completed, cancel the timer
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          _displayedText,
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'hind_semibold',
            color: widget.color, // Use the provided text color
          ),
        ),
      ),
    );
  }
}
