// ignore_for_file: file_names, deprecated_member_use, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:notes/auth/login.dart';
import 'package:notes/core/api/end_point.dart';
import 'package:notes/core/cache/cache_helper.dart';
import 'package:notes/core/constants/appcolors.dart';
import 'package:notes/home/home_page.dart';
import 'package:notes/widgets/app_background.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _iconController;

  late AnimationController _btnController;

  late Animation<double> _scaleAnim;
  late Animation<double> _rotationAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    _scaleAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    _rotationAnim = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    _fadeAnim = CurvedAnimation(parent: _btnController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeOut));

    _checkLoginStatus();
  }

  final SecureCacheHelper _secureCacheHelper = SecureCacheHelper();
  Future<void> _checkLoginStatus() async {
    final String? token = await _secureCacheHelper.getData(key: ApiKey.token);

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeNotesPage()),
        (route) => false,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _iconController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Appcolors.blueAccent.withOpacity(0.7),
                          blurRadius: 35,
                          spreadRadius: 8,
                        ),
                      ],
                      gradient: const LinearGradient(
                        colors: [Appcolors.blue, Appcolors.kPrimary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Transform.rotate(
                      angle: _rotationAnim.value,
                      child: Transform.scale(
                        scale: _scaleAnim.value,
                        child: Padding(
                          padding: EdgeInsets.all(28.0),
                          child: Image.asset(
                            "assets/image/notes-.png",
                            height: 85,
                            width: 85,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: const Text(
                    'مرحبًا بك في ملاحظاتي',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Appcolors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
