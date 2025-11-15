import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';
import 'screens/welcome_screen.dart';

void main() {
  // Memastikan binding Flutter siap sebelum mengatur SystemChrome
  WidgetsFlutterBinding.ensureInitialized();

  // Mengatur tampilan Status Bar (Sinyal, Baterai) agar transparan & ikon putih
  // Ini membuat desain terlihat 'full screen' dan modern
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Kunci orientasi layar ke Portrait (biar tampilan gak hancur kalau HP dimiringin)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SmartUtbApp());
}

class SmartUtbApp extends StatelessWidget {
  const SmartUtbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hilangkan pita 'Debug' di pojok kanan
      title: 'SmartUTB Assistant',
      
      // --- GLOBAL THEME CONFIGURATION ---
      // Mengatur gaya default aplikasi di satu tempat
      theme: ThemeData(
        useMaterial3: true,
        
        // Warna dasar background aplikasi (Dark Mode)
        scaffoldBackgroundColor: kDarkBg,
        
        // Mengatur Font Default menjadi Poppins untuk SELURUH aplikasi
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white, // Warna teks default putih
            displayColor: Colors.white,
          ),
        ),

        // Skema warna utama
        colorScheme: ColorScheme.fromSeed(
          seedColor: kUtbGreen,
          brightness: Brightness.dark,
          primary: kUtbGreen,
          secondary: kUtbBlue,
        ),

        // Default style untuk AppBar (biar konsisten)
        appBarTheme: const AppBarTheme(
          backgroundColor: kDarkBg,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      
      // Halaman Pertama
      home: WelcomeScreen(),
    );
  }
}