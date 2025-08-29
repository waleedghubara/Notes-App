// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'dart:math' as math;
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:notes/auth/signup.dart';
import 'package:notes/core/api/api_consumer.dart';
import 'package:notes/core/api/dio_consumer.dart';
import 'package:notes/core/api/end_point.dart';
import 'package:notes/core/cache/cache_helper.dart';
import 'package:notes/core/constants/appcolors.dart';
import 'package:notes/core/erorr/exception.dart';
import 'package:notes/data/model/signin_model.dart';
import 'package:notes/home/home_page.dart';
import 'package:notes/widgets/AnimatedSlideMessage.dart';
import 'package:notes/widgets/CustomTextField.dart';
import 'package:notes/widgets/app_background.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late AnimationController _controller;
  late AnimationController _iconController;
  late AnimationController _btnController;
  final ApiConsumer api = DioConsumer(dio: Dio());
  bool _isSubmitting = false;
  Future<void> signinApi() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      showTopMessage(context, "من فضلك املى كل البيانات", MessageType.error);
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailCtrl.text.trim())) {
      showTopMessage(context, "البريد الإلكتروني غير صالح", MessageType.error);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await api.post(
        EndPoint.login,
        data: {
          "email": _emailCtrl.text.trim(),
          "password": _passwordCtrl.text.trim(),
        },
      );

      final json = response is String ? jsonDecode(response) : response;

      if (json is Map<String, dynamic>) {
        final signInModel = SigninModel.fromJson(json);

        if (signInModel.status == 'success') {
          showTopMessage(context, signInModel.message, MessageType.success);
          await SecureCacheHelper().saveData(
            key: ApiKey.id,
            value: signInModel.id,
          );
          await SecureCacheHelper().saveData(
            key: ApiKey.token,
            value: signInModel.token,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeNotesPage()),
          );
        } else {
          showTopMessage(context, signInModel.message, MessageType.error);
        }
      } else {
        showTopMessage(
          context,
          "استجابة غير متوقعة من السيرفر",
          MessageType.error,
        );
      }
    } on ServerException catch (e) {
      showTopMessage(context, "خطأ في السيرفر: $e", MessageType.error);
    } catch (e) {
      showTopMessage(context, "حصل خطأ: $e", MessageType.error);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _iconController.dispose();
    _btnController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Widget _buildAnimatedField(Widget child, double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = Tween<double>(begin: 0, end: 1)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  delay,
                  min(delay + 0.5, 1.0),
                  curve: Curves.easeIn,
                ),
              ),
            )
            .value;

        final offsetY = Tween<double>(begin: 40, end: 0)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  delay,
                  min(delay + 0.6, 1.0),
                  curve: Curves.easeOut,
                ),
              ),
            )
            .value;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(offset: Offset(0, offsetY), child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _iconController,
                        builder: (context, child) {
                          final scale =
                              1 +
                              0.1 * math.sin(_iconController.value * math.pi);
                          final angle =
                              0.05 * math.sin(_iconController.value * math.pi);
                          return Transform.rotate(
                            angle: angle,
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Appcolors.blue,
                                      Appcolors.kPrimary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.perm_identity_outlined,
                                  size: 70,
                                  color: Appcolors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),

                      CustomTextField(
                        controller: _emailCtrl,
                        label: 'البريد الإلكتروني',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: _passwordCtrl,
                        label: "كلمة المرور",
                        icon: Icons.lock,
                        keyboardType: TextInputType.emailAddress,
                        isPassword: true,
                      ),

                      const SizedBox(height: 30),

                      _buildAnimatedField(
                        GestureDetector(
                          onTap: _isSubmitting ? null : signinApi,
                          child: AnimatedBuilder(
                            animation: _btnController,
                            builder: (_, __) {
                              final glow =
                                  6 +
                                  (4 *
                                      math.sin(
                                        _btnController.value * math.pi * 2,
                                      ));
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: _isSubmitting
                                        ? [
                                            Colors.grey.shade700,
                                            Colors.grey.shade800,
                                          ]
                                        : [Appcolors.blue, Appcolors.kPrimary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Appcolors.blueAccent.withOpacity(
                                        0.6,
                                      ),
                                      blurRadius: glow,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isSubmitting
                                      ? const CircularProgressIndicator(
                                          color: Appcolors.white,
                                        )
                                      : const Text(
                                          'دخول',
                                          style: TextStyle(
                                            color: Appcolors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                        0.5,
                      ),
                      const SizedBox(height: 20),

                      _buildAnimatedField(
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegistrationPage(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'ليس لديك حساب؟',
                                style: TextStyle(color: Appcolors.white70),
                              ),
                              const Text(
                                ' أنشئ حسابًا',
                                style: TextStyle(
                                  color: Appcolors.blue,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        0.7,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
