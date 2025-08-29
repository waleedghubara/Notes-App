// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/core/api/api_consumer.dart';
import 'package:notes/core/api/dio_consumer.dart';
import 'package:notes/core/api/end_point.dart';
import 'package:notes/core/cache/cache_helper.dart';
import 'package:notes/core/constants/appcolors.dart';
import 'package:notes/data/model/UserModel.dart';
import 'package:notes/widgets/AnimatedSlideMessage.dart';
import 'package:notes/widgets/app_background.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bgController;
  late AnimationController _ctaController;

  final ApiConsumer api = DioConsumer(dio: Dio());
  bool _isSubmitting = false;
  final SecureCacheHelper _secureCacheHelper = SecureCacheHelper();
  UserData? userProfile;

  Future<void> profileApi() async {
    final String? id = await _secureCacheHelper.getData(key: 'id');
    if (id == null) {
      showTopMessage(
        context,
        "لم يتم العثور على معرف المستخدم",
        MessageType.error,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await api.get(
        EndPoint.show,
        queryParameters: {"id": id},
      );

      final json = response is String ? jsonDecode(response) : response;

      if (json is Map<String, dynamic>) {
        if (json['status'] == "success") {
          if (json['status'] == "success") {
            final userModel = UserModel.fromJson(json);
            userProfile = userModel.data; // مباشرة مش first
            setState(() {});
          }
        } else {
          showTopMessage(context, json['message'], MessageType.error);
        }
      } else {
        showTopMessage(
          context,
          "استجابة غير متوقعة من السيرفر",
          MessageType.error,
        );
      }
    } catch (e) {
      showTopMessage(
        context,
        "حدث خطأ أثناء جلب البيانات: $e",
        MessageType.error,
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void initState() {
    profileApi();
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
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _ctaController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    double delay,
  ) {
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
            child: _GlassCard(
              child: ListTile(
                leading: Icon(icon, color: Appcolors.white),
                title: Text(
                  label,
                  style: GoogleFonts.cairo(
                    color: Appcolors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  value,
                  style: GoogleFonts.cairo(
                    color: Appcolors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 10) {
          Navigator.pop(context);
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _isSubmitting
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Appcolors.white,
                          ),
                        )
                      : Column(
                          children: [
                            _AnimatedHeading(
                              controller: _controller,
                              text: "الملف الشخصي",
                            ),
                            const SizedBox(height: 20),

                            AnimatedBuilder(
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
                                        width: 180,
                                        height: 170,
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape
                                              .circle, // مهم عشان يكون دائري
                                          color: Appcolors.white12,
                                          border: Border.all(
                                            color: Appcolors.white.withOpacity(
                                              0.5,
                                            ),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromARGB(
                                                85,
                                                68,
                                                137,
                                                255,
                                              ).withOpacity(0.2),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                            ),
                                            BoxShadow(
                                              color: const Color.fromARGB(
                                                33,
                                                68,
                                                137,
                                                255,
                                              ).withOpacity(0.35),
                                              blurRadius: 22,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: userProfile != null
                                              ? Image.network(
                                                  "${EndPoint.baseUrlImage}/${userProfile!.profile}",
                                                  fit: BoxFit.cover,
                                                  width: 150,
                                                  height: 150,
                                                )
                                              : _ShimmerIcon(
                                                  controller: _bgController,
                                                  child: const Icon(
                                                    Icons.image,
                                                    size: 38,
                                                    color: Appcolors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 30),

                            // Cards
                            _buildInfoCard(
                              "الاسم",
                              userProfile?.username ?? "اسم غير متوفر",
                              Icons.person,
                              0.1,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoCard(
                              "البريد الإلكتروني",
                              userProfile?.email ?? "بريد  غير متوفر",
                              Icons.email,
                              0.2,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoCard(
                              "رقم الهاتف",
                              userProfile?.phone ?? "هاتف  غير متوفر",
                              Icons.phone,
                              0.3,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoCard(
                              "العمر",
                              userProfile != null
                                  ? "${userProfile!.age} سنة"
                                  : "غير متوفر",
                              Icons.cake,
                              0.4,
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

/// ===== Heading متحرك بنفس ستايل signup =====
class _AnimatedHeading extends StatelessWidget {
  final AnimationController controller;
  final String text;
  const _AnimatedHeading({required this.controller, required this.text});

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
                  colors: [Colors.cyanAccent, Colors.purpleAccent],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Appcolors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Appcolors.white.withOpacity(0.12)),
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
                Colors.white.withOpacity(0.35),
                Colors.white,
                Colors.white.withOpacity(0.35),
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
