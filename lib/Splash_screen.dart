import 'dart:async';
import 'package:akshaya_flutter/Common/Constants.dart';
import 'package:akshaya_flutter/Languagescreen.dart';
import 'package:akshaya_flutter/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isLogin = false;
  bool welcome = false;
  int langID = 0;

  @override
  void initState() {
    super.initState();
    loadData();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
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
      // Navigator.of(context).pushReplacement(MaterialPageRoute(
      //   builder: (context) => homepage(),
      // ));
    } else {
      if (welcome) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LanguageScreen()),
        );
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
        child: Container(
          height: MediaQuery.of(context).size.height, // Set container height to the screen height
          child: Stack(
            children: [
              // Background Image
              Image.asset(
                'assets/appbg.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              // Background Color with Opacity
              Container(
                color: Color(0x8D000000), // Background color with opacity
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
                            'assets/ic_logo.png',
                            width: 200,
                            height: 200,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16), // Add spacing between logo and text
                    // Typewriter Text
                    TypewriterText(
                      text: "3F Oil Palm",
                      color: Color(0xFFCE0E2D),
                    ),
                    // Add spacing between the two lines
                    TypewriterText(
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

  TypewriterText({
    required this.text,
    required this.color,
  });

  @override
  _TypewriterTextState createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = ""; // Initial empty text
  int _index = 0;   // Index for tracking characters

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




