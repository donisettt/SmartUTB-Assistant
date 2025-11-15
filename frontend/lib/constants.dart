import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Warna Utama
const Color kPrimaryColor = Color(0xFF0F1C25); // Darker Navy
const Color kSecondaryColor = Color(0xFF162A38); // Lighter Navy
const Color kAccentColor = Color(0xFF265E9E);  // Blue
const Color kGlowColor = Color(0xFF4CA1AF);    // Cyan for Glow effects

// --- WARNA TEMA UTB PREMIUM ---
const Color kDarkBg = Color(0xFF0B1218);      // Hitam kehijauan (Deep Dark Teal)
const Color kInputBg = Color(0xFF16202A);     // Warna input field gelap

// Warna Aksen untuk Gradient & Glow
const Color kUtbBlue = Color(0xFF2196F3);     // Biru cerah
const Color kUtbGreen = Color(0xFF00E676);    // Hijau Neon (Premium look)
const Color kUtbDarkBlue = Color(0xFF1565C0); // Biru Tua

// Gaya Teks Premium
TextStyle kTitleStyle = GoogleFonts.poppins(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Colors.white,
  height: 1.2,
);

TextStyle kSubtitleStyle = GoogleFonts.poppins(
  fontSize: 14,
  color: Colors.white70,
  height: 1.5,
);

TextStyle kButtonTextStyle = GoogleFonts.poppins(
  fontSize: 16, 
  fontWeight: FontWeight.w600,
  letterSpacing: 1,
);