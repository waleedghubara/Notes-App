// ignore_for_file: deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'package:notes/core/constants/appcolors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final int minLines;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      keyboardType: widget.keyboardType,
      minLines: widget.minLines,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      style: const TextStyle(color: Appcolors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Appcolors.white.withOpacity(0.06),
        hintText: widget.label,
        labelStyle: const TextStyle(color: Appcolors.white),
        prefixIcon: Icon(widget.icon, color: Appcolors.white),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: Appcolors.white,
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : null,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Appcolors.white.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Appcolors.white),
        ),
      ),
      validator: (v) => (v ?? '').isEmpty ? '${widget.label} مطلوب' : null,
    );
  }
}
