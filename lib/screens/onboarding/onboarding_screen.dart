import 'package:flutter/material.dart';
import 'package:moodfit/screens/auth/login_screen.dart';
import 'package:moodfit/utils/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to MoodFit',
      description:
          'Your personal fitness companion that adapts to how you feel',
      image: 'assets/backgrounds/dashboard_bg.jpg',
      icon: Icons.fitness_center,
    ),
    OnboardingPage(
      title: 'Match Your Mood',
      description:
          'Get personalized workout recommendations based on your current mood and energy level',
      image: 'assets/backgrounds/meditation_bg.jpg',
      icon: Icons.mood,
    ),
    OnboardingPage(
      title: 'Adaptive Workouts',
      description:
          'From energizing routines to calming exercises, find the perfect match for your day',
      image: 'assets/backgrounds/yoga_bg.jpg',
      icon: Icons.bolt,
    ),
    OnboardingPage(
      title: 'Track Your Progress',
      description:
          'See how your workouts affect your mood and build healthier habits over time',
      image: 'assets/backgrounds/jogging_bg.jpg',
      icon: Icons.bar_chart,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = page == _pages.length - 1;
    });

    // Reset and start animation for the new page
    _animationController.reset();
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);

    // ignore: use_build_context_synchronously
    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_pages[index].image),
                    fit: BoxFit.cover,
                    colorFilter: const ColorFilter.mode(
                      Colors.black54,
                      BlendMode.darken,
                    ),
                  ),
                ),
              );
            },
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: () => _completeOnboarding(context),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // Animation and content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animation
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: Tween<double>(begin: 0.5, end: 1.0)
                                      .animate(CurvedAnimation(
                                        parent: _animationController,
                                        curve: Curves.elasticOut,
                                      ))
                                      .value,
                                  child: child,
                                );
                              },
                              child: Container(
                                height: screenHeight * 0.2,
                                width: screenHeight * 0.2,
                                decoration: BoxDecoration(
                                  color: themeProvider.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    _pages[index].icon,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Text content
                            Column(
                              children: [
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _animationController.value,
                                      child: child,
                                    );
                                  },
                                  child: Text(
                                    _pages[index].title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _animationController.value,
                                      child: Transform.translate(
                                        offset: Offset(
                                            0,
                                            20 *
                                                (1 -
                                                    _animationController
                                                        .value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    _pages[index].description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Indicators and buttons
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            height: 10,
                            width: _currentPage == index ? 30 : 10,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? themeProvider.primaryColor
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 30),

                      // Next/Get Started button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLastPage
                              ? () => _completeOnboarding(context)
                              : _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            _isLastPage ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
  });
}
