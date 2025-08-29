// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/core/api/api_consumer.dart';
import 'package:notes/core/api/dio_consumer.dart';
import 'package:notes/core/api/end_point.dart';
import 'package:notes/core/constants/appcolors.dart';
import 'package:notes/core/erorr/exception.dart';
import 'package:notes/data/model/modelnotes_add.dart';
import 'package:notes/home/home_page.dart';
import 'package:notes/widgets/AnimatedSlideMessage.dart';
import 'package:notes/widgets/CustomTextField.dart';
import 'package:notes/widgets/app_background.dart';

class EditnotesPage extends StatefulWidget {
  final int id;
  final String title;
  final String content;
  const EditnotesPage({
    super.key,
    required this.title,
    required this.content,
    required this.id,
  });

  @override
  State<EditnotesPage> createState() => _EditnotesPageState();
}

class _EditnotesPageState extends State<EditnotesPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _imageController = TextEditingController();
  late AnimationController _animationController;
  final ApiConsumer api = DioConsumer(dio: Dio());
  late AnimationController _bgController;
  late AnimationController _fieldsController;
  bool _isSubmitting = false;

  Future<void> addNotesApi() async {
    if (_titleController.text.isEmpty || _detailsController.text.isEmpty) {
      showTopMessage(context, "من فضلك املى كل البيانات", MessageType.error);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await api.post(
        EndPoint.notesedit,
        data: {
          "id": widget.id,
          "titel": _titleController.text.trim(),
          "content": _detailsController.text.trim(),
        },
      );

      final json = response is String ? jsonDecode(response) : response;

      if (json is Map<String, dynamic>) {
        final signInModel = ModelnotesAdd.fromJson(json);

        if (signInModel.status == "success") {
          showTopMessage(context, signInModel.message, MessageType.success);
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

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _fieldsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _titleController.text = widget.title;
    _detailsController.text = widget.content;
  }

  @override
  void dispose() {
    _bgController.dispose();
    _fieldsController.dispose();
    _animationController.dispose();
    _titleController.dispose();
    _detailsController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),

      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        " تعديل الملاحظة",
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Appcolors.white,
                        ),
                      ),
                      const SizedBox(height: 30),

                      GlassCard(
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _titleController,
                              label: widget.title,
                              icon: Icons.title,
                            ),
                            const SizedBox(height: 15),
                            CustomTextField(
                              controller: _detailsController,
                              label: widget.content,
                              maxLines: 10,
                              minLines: 10,
                              icon: Icons.description,
                            ),

                            const SizedBox(height: 25),
                            _isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Appcolors.white,
                                  )
                                : AnimatedButton(
                                    text: "حفظ الملاحظة",
                                    onPressed: addNotesApi,
                                    controller: _animationController,
                                  ),
                            SizedBox(height: 10),

                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeNotesPage(),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'الغاء',
                                    style: TextStyle(
                                      color: Appcolors.blue,
                                      fontWeight: FontWeight.bold,
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedHeading extends StatelessWidget {
  final String text;
  const AnimatedHeading({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Appcolors.white,
        shadows: [
          Shadow(blurRadius: 10, color: Colors.black26, offset: Offset(2, 2)),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Appcolors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Appcolors.white.withOpacity(0.2), width: 1),
      ),
      child: child,
    );
  }
}

class AnimatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final AnimationController controller;

  const AnimatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(
        begin: 0.95,
        end: 1.05,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Appcolors.white,
          foregroundColor: Appcolors.blueAccent,
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
