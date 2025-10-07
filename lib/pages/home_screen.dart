import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sports_app/pages/skills_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _getResponsiveFontSize(BuildContext context, double size) {
    double width = MediaQuery.of(context).size.width;
    if (width < 360) return size * 0.85;
    if (width < 600) return size;
    if (width < 900) return size * 1.05;
    return size * 1.1;
  }

  double _getResponsiveSpacing(BuildContext context, double size) {
    double width = MediaQuery.of(context).size.width;
    if (width < 360) return size * 0.8;
    if (width < 600) return size;
    if (width < 900) return size * 1.1;
    return size * 1.2;
  }

  double _getMaxWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 900) return 600;
    if (width > 600) return 500;
    return width;
  }

  void _navigateToSkills() {
    HapticFeedback.mediumImpact();
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SkillsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Fade transition for the incoming page
          final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
            ),
          );

          // Slide transition for the incoming page
          final slideIn = Tween<Offset>(
            begin: const Offset(0.3, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          // Scale transition for the incoming page
          final scaleIn = Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          // Fade out the current page
          final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
            ),
          );

          // Scale out the current page slightly
          final scaleOut = Tween<double>(begin: 1.0, end: 0.95).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
            ),
          );

          return Stack(
            children: [
              // Current page fading/scaling out
              FadeTransition(
                opacity: fadeOut,
                child: ScaleTransition(
                  scale: scaleOut,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFEEF2FF),
                          Color(0xFFFCE7F3),
                          Color(0xFFDDEEFC),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // New page sliding/fading/scaling in
              SlideTransition(
                position: slideIn,
                child: FadeTransition(
                  opacity: fadeIn,
                  child: ScaleTransition(
                    scale: scaleIn,
                    child: child,
                  ),
                ),
              ),
            ],
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEEF2FF),
              Color(0xFFFCE7F3),
              Color(0xFFDDEEFC),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _getMaxWidth(context),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _getResponsiveSpacing(context, 24),
                  vertical: _getResponsiveSpacing(context, 20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          SizedBox(height: _getResponsiveSpacing(context, 40)),
                          Text(
                            'SkillScroll',
                            style: GoogleFonts.poppins(
                              fontSize: _getResponsiveFontSize(context, 42),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1F2937),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Master your skills effortlessly',
                            style: GoogleFonts.poppins(
                              fontSize: _getResponsiveFontSize(context, 16),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Center(
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: _AnimatedDots(),
                        ),
                      ),
                    ),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(
                                maxWidth: 400,
                              ),
                              height: _getResponsiveSpacing(context, 60),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8B5CF6),
                                    Color(0xFF6366F1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(_getResponsiveSpacing(context, 16)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(_getResponsiveSpacing(context, 16)),
                                  onTap: _navigateToSkills,
                                  splashColor: Colors.white.withOpacity(0.2),
                                  highlightColor: Colors.white.withOpacity(0.1),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Get Started',
                                          style: GoogleFonts.poppins(
                                            fontSize: _getResponsiveFontSize(context, 18),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        SizedBox(width: _getResponsiveSpacing(context, 8)),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: _getResponsiveFontSize(context, 24),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: _getResponsiveSpacing(context, 20)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final List<_DotConfig> _dotConfigs = [
    _DotConfig(size: 80, left: 0.15, top: 0.3, duration: 3000, delay: 0),
    _DotConfig(size: 60, left: 0.65, top: 0.2, duration: 2500, delay: 200),
    _DotConfig(size: 40, left: 0.25, top: 0.6, duration: 2800, delay: 400),
    _DotConfig(size: 50, left: 0.7, top: 0.65, duration: 3200, delay: 100),
    _DotConfig(size: 30, left: 0.45, top: 0.45, duration: 2600, delay: 300),
    _DotConfig(size: 35, left: 0.8, top: 0.4, duration: 2900, delay: 500),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _dotConfigs.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: _dotConfigs[index].duration),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: _dotConfigs[i].delay), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    
    double containerSize;
    if (width > 900) {
      containerSize = 350;
    } else if (width > 600) {
      containerSize = width * 0.6;
    } else {
      containerSize = width * 0.7;
    }
    
    containerSize = containerSize.clamp(200.0, 400.0);

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        children: List.generate(_dotConfigs.length, (index) {
          final config = _dotConfigs[index];
          return Positioned(
            left: containerSize * config.left,
            top: containerSize * config.top,
            child: AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: _animations[index].value,
                  child: Container(
                    width: config.size,
                    height: config.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8B5CF6).withOpacity(0.8),
                          const Color(0xFF6366F1).withOpacity(0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class _DotConfig {
  final double size;
  final double left;
  final double top;
  final int duration;
  final int delay;

  _DotConfig({
    required this.size,
    required this.left,
    required this.top,
    required this.duration,
    required this.delay,
  });
}