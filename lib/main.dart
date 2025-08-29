import 'package:flutter/material.dart';
import 'package:notes/core/constants/appcolors.dart';
import 'package:notes/splash/SplashPage.dart';

void main() {
  runApp(const MyNotes());
}

class MyNotes extends StatelessWidget {
  const MyNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Notes App',
        theme: ThemeData(
          fontFamily: "Tajawal",
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Appcolors.kPrimary,
            brightness: Brightness.dark,
          ),
          inputDecorationTheme: _inputDecorationTheme,
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const SplashPage(),
      ),
    );
  }
}

final _inputDecorationTheme = const InputDecorationTheme(
  filled: true,
  fillColor: Color(0xFF1E1E1E),
  iconColor: Appcolors.kPrimary,
  prefixIconColor: Appcolors.kPrimary,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
);
