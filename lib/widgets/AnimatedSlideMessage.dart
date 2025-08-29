// ignore_for_file: file_names

import 'package:flutter/material.dart';

enum MessageType { success, warning, error }

void showTopMessage(BuildContext context, String message, MessageType type) {
  final overlay = Overlay.of(context);
  final color =
      {
        MessageType.success: Colors.green,
        MessageType.warning: Colors.orange,
        MessageType.error: const Color.fromARGB(255, 179, 1, 1),
      }[type]!;

  final overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          top: 20,
          left: MediaQuery.of(context).size.width / 2, // نقطة المنتصف
          child: FractionalTranslation(
            translation: const Offset(-0.5, 0), // عشان تتوسّط أفقيًا
            child: Material(
              color: Colors.transparent,
              child: AnimatedSlideMessage(message: message, color: color),
            ),
          ),
        ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

class AnimatedSlideMessage extends StatefulWidget {
  final String message;
  final Color color;
  const AnimatedSlideMessage({
    super.key,
    required this.message,
    required this.color,
  });

  @override
  State<AnimatedSlideMessage> createState() => _AnimatedSlideMessageState();
}

class _AnimatedSlideMessageState extends State<AnimatedSlideMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // العرض على قد المحتوى
          children: [
            Icon(
              widget.color == Colors.green
                  ? Icons.check_circle
                  : widget.color == Colors.orange
                  ? Icons.warning
                  : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              widget.message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
