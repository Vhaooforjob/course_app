import 'package:flutter/material.dart';
import 'package:course_app/configs/colors.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:course_app/pages/login_page.dart';
import 'registration_page.dart';

class SlideStartPage extends StatefulWidget {
  const SlideStartPage({super.key});

  @override
  State<SlideStartPage> createState() => _SlideStartPageState();
}

class Slide {
  final String imagePath;
  final String? text1;
  final TextStyle? textStyle1;
  final String? text2;
  final TextStyle? textStyle2;
  final String? buttonLogin;
  final String? registerText;

  Slide({
    required this.imagePath,
    this.text1,
    this.textStyle1,
    this.text2,
    this.textStyle2,
    this.buttonLogin,
    this.registerText,
  });
}

class _SlideStartPageState extends State<SlideStartPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Slide> _slides = [
    Slide(
      imagePath: 'assets/images/logo_hela.png',
      text1: 'CHÀO MỪNG BẠN ĐẾN VỚI ',
      textStyle1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      text2: 'HELA COURSES',
      textStyle2: const TextStyle(
          fontSize: 36, fontWeight: FontWeight.bold, color: blue18A0FB),
    ),
    Slide(
      imagePath: 'assets/images/slide2.jpg',
      text1: '“Trải nghiệm học tập dễ dàng và hiệu quả”',
      textStyle1: const TextStyle(
        fontSize: 18,
        // fontWeight: FontWeight.bold,
      ),
    ),
    Slide(
        imagePath: 'assets/images/slide3.jpg',
        text1:
            '"Ứng dụng của chúng tôi giúp bạn tiếp cận kiến thức dễ dàng, mọi lúc, mọi nơi. Đăng ký ngay để bắt đầu hành trình học tập của bạn!"',
        textStyle1: const TextStyle(
          fontSize: 18,
          // fontWeight: FontWeight.bold,
        ),
        buttonLogin: 'Đăng nhập',
        registerText: 'Đăng ký'),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_currentPage < _slides.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/slide_page.png"),
                      fit: BoxFit.cover))),
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return SlidePage(slide: _slides[index]);
            },
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (index) {
                    return Container(
                      width: _currentPage == index ? 22.0 : 8.0,
                      height: _currentPage == index ? 10.0 : 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8.0),
                        color:
                            _currentPage == index ? blue378CE7 : blue378CE7_50,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SlidePage extends StatelessWidget {
  final Slide slide;
  final Animation<double>? animation;

  const SlidePage({super.key, required this.slide, this.animation});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            slide.imagePath,
            height: 250,
          ),
          const SizedBox(height: 70),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: AnimatedOpacity(
                      opacity: animation?.value ?? 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        slide.text1 ?? '',
                        style: slide.textStyle1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if (slide.text2 != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: AnimatedOpacity(
                        opacity: animation?.value ?? 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          slide.text2!,
                          style: slide.textStyle2!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                  if (slide.buttonLogin != null) ...[
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue5AB2FF,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          slide.buttonLogin!,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationScreen(),
                            ),
                          );
                        },
                        child: Text(
                          slide.registerText!,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
