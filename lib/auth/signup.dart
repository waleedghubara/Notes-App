// ignore_for_file: deprecated_member_use, unused_local_variable, avoid_print, use_build_context_synchronously, unused_element
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/auth/login.dart';
import 'package:notes/core/api/api_consumer.dart';
import 'package:notes/core/api/dio_consumer.dart';
import 'package:notes/core/api/end_point.dart';
import 'package:notes/core/cache/cache_helper.dart';
import 'package:notes/core/constants/appcolors.dart';
import 'package:notes/core/erorr/exception.dart';
import 'package:notes/core/functions/upload_images_to_api.dart';
import 'package:notes/data/model/signup_model.dart';
import 'package:notes/widgets/AnimatedSlideMessage.dart';
import 'package:notes/widgets/CustomTextField.dart';
import 'package:notes/widgets/app_background.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final ApiConsumer api = DioConsumer(dio: Dio());
  bool _isSubmitting = false;

  late AnimationController _controller;
  late AnimationController _bgController;
  late AnimationController _ctaController;

  XFile? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
    }
  }

  Future<void> signupApi() async {
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _ageCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty) {
      showTopMessage(context, "من فضلك املى كل البيانات", MessageType.error);
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailCtrl.text)) {
      showTopMessage(context, "البريد الإلكتروني غير صالح", MessageType.error);
      return;
    }
    if (_profileImage == null) {
      showTopMessage(context, "من فضلك يرجى تحميل الصورة", MessageType.warning);
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final response = await api.post(
        EndPoint.signup,
        data: {
          "username": _nameCtrl.text,
          "email": _emailCtrl.text,
          "phone": _phoneCtrl.text,
          "age": _ageCtrl.text,
          "password": _passwordCtrl.text,
          "profile": await uploadImageToAPI(_profileImage!),
        },
        isFromData: true,
      );

      final Map<String, dynamic> json = jsonDecode(response);
      final signUpModel = SignUpModel.fromJson(json);
      showTopMessage(context, signUpModel.message, MessageType.success);
      await SecureCacheHelper().saveData(
        key: ApiKey.token,
        value: signUpModel.token,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      dispose() {
        _controller.dispose();
        _bgController.dispose();
        _ctaController.dispose();
        _nameCtrl.dispose();
        _emailCtrl.dispose();
        _phoneCtrl.dispose();
        _ageCtrl.dispose();
        _passwordCtrl.dispose();
        super.dispose();
      }
    } on ServerException catch (e) {
      showTopMessage(context, "$e", MessageType.error);
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

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _ctaController = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    _ctaController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staggerInterval = 0.12;

    final textFields = [
      _buildTextField(
        _nameCtrl,
        'الاسم الكامل',
        Icons.person,
        0 * staggerInterval,
      ),
      const SizedBox(height: 10),
      _buildTextField(
        _emailCtrl,
        'البريد الإلكتروني',
        Icons.mail,
        1 * staggerInterval,
        type: TextInputType.emailAddress,
      ),
      const SizedBox(height: 10),
      _buildTextField(
        _phoneCtrl,
        'رقم الهاتف',
        Icons.phone,
        2 * staggerInterval,
        type: TextInputType.phone,
      ),
      const SizedBox(height: 10),
      _buildTextField(
        _ageCtrl,
        'العمر',
        Icons.cake,
        3 * staggerInterval,
        type: TextInputType.number,
      ),
      const SizedBox(height: 10),
      _buildTextField(
        _passwordCtrl,
        'كلمة المرور',
        Icons.lock,
        4 * staggerInterval,
        isPassword: true,
      ),
    ];

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // لو السحب من الشمال لليمين
        if (details.delta.dx > 10) {
          Navigator.pop(context); // يرجع للهوم مباشرة
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: AppBackground(
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.6, -0.6),
                          radius: 1.2,
                          colors: [
                            Colors.white.withOpacity(0.06),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Particles
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _AnimatedHeading(controller: _controller),

                          const SizedBox(height: 18),

                          _GlassCard(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, _) {
                                      final scale =
                                          Tween<double>(begin: 0.6, end: 1.0)
                                              .animate(
                                                CurvedAnimation(
                                                  parent: _controller,
                                                  curve: Curves.elasticOut,
                                                ),
                                              )
                                              .value;

                                      final rotation =
                                          Tween<double>(begin: -0.15, end: 0)
                                              .animate(
                                                CurvedAnimation(
                                                  parent: _controller,
                                                  curve: Curves.easeOutBack,
                                                ),
                                              )
                                              .value;

                                      return Transform.rotate(
                                        angle: rotation,
                                        child: Transform.scale(
                                          scale: scale,
                                          child: Hero(
                                            tag: 'profileAvatar',
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Appcolors.blueAccent
                                                        .withOpacity(0.35),
                                                    blurRadius: 22,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: CircleAvatar(
                                                radius: 56,
                                                backgroundColor:
                                                    Appcolors.white12,
                                                backgroundImage:
                                                    _profileImage != null
                                                    ? FileImage(
                                                        File(
                                                          _profileImage!.path,
                                                        ),
                                                      )
                                                    : null,
                                                child: _profileImage == null
                                                    ? _ShimmerIcon(
                                                        controller:
                                                            _bgController,
                                                        child: const Icon(
                                                          Icons
                                                              .perm_identity_outlined,
                                                          size: 38,
                                                          color:
                                                              Appcolors.white,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "صوره شخصيه",
                                  style: TextStyle(
                                    color: Appcolors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 22),

                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      ...textFields,
                                      const SizedBox(height: 22),
                                      // زرار CTA مع Pulse + Slide
                                      AnimatedBuilder(
                                        animation: Listenable.merge([
                                          _controller,
                                          _ctaController,
                                        ]),
                                        builder: (context, _) {
                                          final slideY =
                                              Tween<double>(begin: 40, end: 0)
                                                  .animate(
                                                    CurvedAnimation(
                                                      parent: _controller,
                                                      curve: const Interval(
                                                        0.75,
                                                        1.0,
                                                        curve: Curves.easeOut,
                                                      ),
                                                    ),
                                                  )
                                                  .value;

                                          final opacity =
                                              Tween<double>(begin: 0, end: 1)
                                                  .animate(
                                                    CurvedAnimation(
                                                      parent: _controller,
                                                      curve: const Interval(
                                                        0.75,
                                                        1.0,
                                                      ),
                                                    ),
                                                  )
                                                  .value;

                                          final pulse =
                                              1 +
                                              (0.02 *
                                                  math.sin(
                                                    _ctaController.value *
                                                        math.pi *
                                                        2,
                                                  ));

                                          return Opacity(
                                            opacity: opacity,
                                            child: Transform.translate(
                                              offset: Offset(0, slideY),
                                              child: Transform.scale(
                                                scale: pulse,
                                                child: ElevatedButton(
                                                  onPressed: _isSubmitting
                                                      ? null
                                                      : signupApi,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Appcolors.kPrimary,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 48,
                                                          vertical: 14,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            28,
                                                          ),
                                                    ),
                                                    elevation: 10,
                                                  ),
                                                  child: AnimatedSwitcher(
                                                    duration: const Duration(
                                                      milliseconds: 350,
                                                    ),
                                                    transitionBuilder:
                                                        (
                                                          child,
                                                          anim,
                                                        ) => ScaleTransition(
                                                          scale: CurvedAnimation(
                                                            parent: anim,
                                                            curve: Curves
                                                                .easeOutBack,
                                                          ),
                                                          child: child,
                                                        ),
                                                    child: _isSubmitting
                                                        ? const SizedBox(
                                                            key: ValueKey(
                                                              'loader',
                                                            ),
                                                            height: 20,
                                                            width: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2.2,
                                                                  color:
                                                                      Appcolors
                                                                          .white,
                                                                ),
                                                          )
                                                        : const Text(
                                                            'تسجيل حساب',
                                                            key: ValueKey(
                                                              'label',
                                                            ),
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Appcolors
                                                                  .white,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    double delay, {
    TextInputType? type,
    bool isPassword = false,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = Tween<double>(begin: 0, end: 1)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  delay,
                  math.min(delay + 0.6, 1.0),
                  curve: Curves.easeIn,
                ),
              ),
            )
            .value;

        final offsetX = Tween<double>(begin: 90, end: 0)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  delay,
                  math.min(delay + 0.6, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              ),
            )
            .value;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(offsetX, 0),
            child: _GlowField(
              child: CustomTextField(
                controller: ctrl,
                label: label,
                icon: icon,
                keyboardType: type ?? TextInputType.text,
                isPassword: isPassword,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedHeading extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedHeading({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final fade = Tween<double>(begin: 0, end: 1)
            .animate(
              CurvedAnimation(
                parent: controller,
                curve: const Interval(0, 0.5),
              ),
            )
            .value;

        final wave = math.sin(controller.value * math.pi) * 4;

        return Opacity(
          opacity: fade,
          child: Transform.translate(
            offset: Offset(0, wave),
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.cyanAccent, Colors.purpleAccent],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: const Text(
                'تسجيل حساب',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      blurRadius: 16,
                      color: Colors.black54,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Appcolors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Appcolors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Appcolors.black.withOpacity(0.35),
            blurRadius: 26,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ShimmerIcon extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  const _ShimmerIcon({required this.child, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        return ShaderMask(
          shaderCallback: (bounds) {
            final w = bounds.width;
            return LinearGradient(
              begin: Alignment(-1 + t * 2, 0),
              end: Alignment(1 + t * 2, 0),
              colors: [
                Appcolors.white.withOpacity(0.35),
                Appcolors.white,
                Appcolors.white.withOpacity(0.35),
              ],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(Rect.fromLTWH(0, 0, w, bounds.height));
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
    );
  }
}

class _GlowField extends StatefulWidget {
  final Widget child;
  const _GlowField({required this.child});

  @override
  State<_GlowField> createState() => _GlowFieldState();
}

class _GlowFieldState extends State<_GlowField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () => setState(() => _focused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: Appcolors.blueAccent.withOpacity(0.35),
                  blurRadius: 18,
                  spreadRadius: 1.5,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Focus(focusNode: _focusNode, child: widget.child),
    );
  }
}
