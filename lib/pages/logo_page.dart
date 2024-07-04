import 'package:flutter/material.dart';
import 'slide_start_page.dart';
import 'dart:async';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class LogoPage extends StatefulWidget {
  const LogoPage({super.key});

  @override
  State<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {
  bool showLoadingButton = false;
  @override
  void initState() {
    super.initState();
    // Hiển thị nút loading sau 2 giây
    Timer(const Duration(seconds: 2), () {
      setState(() {
        showLoadingButton = true;
      });
    });
    // Chuyển sang trang khác sau 5 giây
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SlideStartPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/logo_page.png"),
                    fit: BoxFit.cover)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  WidgetAnimator(
                    incomingEffect: WidgetTransitionEffects.incomingScaleDown(),
                    atRestEffect: WidgetRestingEffects.bounce(),
                    outgoingEffect: WidgetTransitionEffects.outgoingScaleUp(),
                    child: const Text(
                      'HELA COURSES',
                      style: TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // if (showLoadingButton)
          //   const Align(
          //       alignment: Alignment.bottomCenter,
          //       child: Padding(
          //         padding: EdgeInsets.all(16.0),
          //         child: CircularProgressIndicator(
          //           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //         ),
          //       )),
        ],
      ),
    );
  }
}
