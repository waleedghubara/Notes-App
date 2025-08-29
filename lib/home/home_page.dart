// ignore_for_file: deprecated_member_use, dead_code, use_build_context_synchronously
import 'dart:convert';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/auth/profile.dart';
import 'package:notes/core/api/api_consumer.dart';
import 'package:notes/core/api/dio_consumer.dart';
import 'package:notes/core/api/end_point.dart';
import 'package:notes/core/cache/cache_helper.dart';
import 'package:notes/core/constants/appcolors.dart';
import 'package:notes/core/erorr/exception.dart';
import 'package:notes/data/model/modelnotes_add.dart';
import 'package:notes/data/model/modelnotes_view.dart';
import 'package:notes/home/addnote_page.dart';
import 'package:notes/home/editnotes_page.dart';
import 'package:notes/splash/SplashPage.dart';
import 'package:notes/widgets/AnimatedSlideMessage.dart';
import 'package:notes/widgets/app_background.dart';

class HomeNotesPage extends StatefulWidget {
  const HomeNotesPage({super.key});

  @override
  State<HomeNotesPage> createState() => _HomeNotesPageState();
}

class _HomeNotesPageState extends State<HomeNotesPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fabController;
  final ApiConsumer api = DioConsumer(dio: Dio());
  bool _isSubmitting = false;
  final SecureCacheHelper _secureCacheHelper = SecureCacheHelper();
  List<Note> _notes = [];

  Future<void> notesViewApp() async {
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
        EndPoint.notesview,
        queryParameters: {"id": id},
      );

      final json = response is String ? jsonDecode(response) : response;

      if (json is Map<String, dynamic>) {
        final notesResponse = NotesResponse.fromJson(json);

        if (notesResponse.status == "success") {
          _notes = notesResponse.data;
        } else {
          showTopMessage(context, notesResponse.message, MessageType.warning);
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
        "حدث خطأ أثناء جلب الملاحظات: $e",
        MessageType.error,
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    notesViewApp();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  Future<void> removeNote(int id, String idimage) async {
    try {
      final response = await api.post(
        EndPoint.notesdelete,
        data: {"id": id, "imagename": idimage},
      );
      final json = response is String ? jsonDecode(response) : response;
      if (json is Map<String, dynamic>) {
        final signInModel = ModelnotesAdd.fromJson(json);

        if (signInModel.status == "success") {
          showTopMessage(context, signInModel.message, MessageType.success);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeNotesPage()),
            (route) => false,
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
  void dispose() {
    _controller.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.person_outline_rounded,
                          color: Appcolors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 700,
                              ),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const ProfilePage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOutCubic;

                                    var tween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                            ),
                          );
                        },
                      ),
                      Text(
                        "ملاحظاتي",
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Appcolors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Appcolors.white,
                          size: 28,
                        ),
                        onPressed: () async {
                          await SecureCacheHelper().removeData(
                            key: ApiKey.token,
                          );
                          await SecureCacheHelper().removeData(key: ApiKey.id);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => SplashPage(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isSubmitting
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Appcolors.white,
                          ),
                        )
                      : _notes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/image/notes-app.png",
                                height: 250,
                                width: 250,
                              ),
                              Text(
                                " لا توجد ملاحظات بعد ✨",
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Appcolors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            final note = _notes[index];
                            final delay = index * 0.15;

                            return AnimatedBuilder(
                              animation: _controller,
                              builder: (context, _) {
                                final opacity = Tween<double>(begin: 0, end: 1)
                                    .animate(
                                      CurvedAnimation(
                                        parent: _controller,
                                        curve: Interval(
                                          delay,
                                          math.min(delay + 0.5, 1.0),
                                          curve: Curves.easeIn,
                                        ),
                                      ),
                                    )
                                    .value;

                                final offsetY = Tween<double>(begin: 80, end: 0)
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
                                    offset: Offset(0, offsetY),
                                    child: _GlassCard(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                          Navigator.of(
                                            context,
                                          ).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditnotesPage(
                                                    title: note.titel,
                                                    content: note.content,
                                                    id: note.notesId,
                                                  ),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      "${EndPoint.baseUrlImage}/${note.notesImage}",

                                                  width: 90,
                                                  height: 90,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                        color: Colors.grey[200],
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.image,
                                                            size: 35,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => Container(
                                                        color: Appcolors.grey,
                                                        child: const Icon(
                                                          Icons.book,
                                                          size: 40,
                                                          color:
                                                              Appcolors.white,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      note.titel,
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Appcolors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      note.content,
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 14,
                                                        color:
                                                            Appcolors.white70,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Center(
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.redAccent,
                                                  ),
                                                  onPressed: () => removeNote(
                                                    note.notesId,
                                                    note.notesImage,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),

        floatingActionButton: AnimatedBuilder(
          animation: _fabController,
          builder: (_, child) {
            final scale =
                1 + (0.05 * math.sin(_fabController.value * math.pi * 2));
            return Transform.scale(
              scale: scale,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF030C7F),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddNotePage(),
                    ),
                  );
                },
                child: const Icon(Icons.add, size: 30, color: Appcolors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Appcolors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Appcolors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
