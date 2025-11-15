import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Setup Animasi "Bernafas" untuk Robot
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg, // Gunakan kDarkBg dari constants (atau Color(0xFF0B1218))
      body: Stack(
        children: [
          // 1. BACKGROUND DECORATION
          // Menggunakan Positioned.fill agar background full
          Positioned.fill(
             child: Container(
               color: kDarkBg,
               child: Stack(
                 children: [
                    Positioned(
                      top: -100, left: -50, child: _buildBlurCircle(kUtbDarkBlue, 300),
                    ),
                    Positioned(
                      bottom: -100, right: -50, child: _buildBlurCircle(kUtbGreen, 300),
                    ),
                 ]
               )
             )
          ),
          
          // 2. MAIN CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),

                  // --- ROBOT AREA (ANIMATED) ---
                  ScaleTransition(
                    scale: _animation,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            kUtbGreen.withOpacity(0.2), // Pakai Hijau UTB
                            Colors.transparent,
                          ],
                          radius: 0.7,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kUtbGreen.withOpacity(0.1),
                            blurRadius: 50,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      // Ganti dengan aset robot kamu
                      child: Image.asset('assets/robot.png', height: 180),
                    ),
                  ),

                  SizedBox(height: 50),

                  // --- TEXT AREA ---
                  Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03), // Transparan sangat tipis
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Welcome to\nSmartUTB",
                          textAlign: TextAlign.center,
                          style: kTitleStyle,
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Asisten akademik cerdas siap membantu perjalanan kuliahmu di UTB.",
                          textAlign: TextAlign.center,
                          style: kSubtitleStyle,
                        ),
                      ],
                    ),
                  ),

                  Spacer(),

                  // --- BUTTONS AREA ---
                  
                  // Tombol 1: Start Chatting (GUEST)
                  // SUDAH DI-UPDATE: Warnanya sekarang Biru ke Hijau (Sama kayak Login)
                  _buildPrimaryButton(
                    text: "Start Chatting",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen(isGuest: true)),
                      );
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Tombol 2: Login Mahasiswa
                  _buildSecondaryButton(
                    text: "Login Mahasiswa",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDER METHODS ---

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  // Widget Tombol Utama (UPDATED GRADIENT)
  Widget _buildPrimaryButton({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // --- BAGIAN INI YANG DIUBAH ---
        gradient: LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF00C853)], // Biru -> Hijau
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00C853).withOpacity(0.3), // Shadow Hijau
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        // -----------------------------
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onPressed,
        child: Text(text, style: kButtonTextStyle.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildSecondaryButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white.withOpacity(0.05),
        ),
        onPressed: onPressed,
        child: Text(text, style: kButtonTextStyle.copyWith(color: Colors.white)),
      ),
    );
  }
}