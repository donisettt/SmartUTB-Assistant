import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui'; 
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  final String baseUrl = "https://donisettt.pythonanywhere.com";

  // --- LOGIKA LOGIN (Sama seperti sebelumnya) ---
  Future<void> _handleLogin() async {
    String nim = _nimController.text;
    String password = _passController.text;

    if (nim.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Isi NIM dan Password dulu ya!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nim": nim, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              isGuest: false,
              userName: data['data']['name'],
              userNim: data['data']['nim'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Login Gagal"), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal koneksi ke server"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- WIDGET BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      // PENTING: backgroundColor jangan diset di sini agar tidak menutupi layer bawah
      // biarkan default atau transparan karena kita pakai Stack background
      body: Stack(
        children: [
          // --- LAYER 1: BACKGROUND FULL SCREEN ---
          // Menggunakan Positioned.fill agar mengisi SELURUH layar HP dari atas sampai bawah
          Positioned.fill(
            child: Container(
              color: kDarkBg, // Warna dasar
              child: Stack(
                children: [
                  Positioned(
                    top: -60, left: -60, child: _buildGlowCircle(kUtbDarkBlue),
                  ),
                  Positioned(
                    top: 150, right: -40, child: _buildGlowCircle(kUtbGreen.withOpacity(0.5)),
                  ),
                  Positioned(
                    bottom: -60, left: 20, child: _buildGlowCircle(kUtbBlue.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
          ),

          // --- LAYER 2: KONTEN SCROLLABLE ---
          // Konten ini transparan backgroundnya, jadi Layer 1 akan terlihat
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: statusBarHeight + 60,
                // Padding bawah dinamis + jarak aman
                bottom: bottomPadding + 40, 
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- GAMBAR ROBOT ---
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/robot.png'),
                        fit: BoxFit.contain,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kUtbGreen.withOpacity(0.2),
                          blurRadius: 50,
                          offset: Offset(0, 10),
                        )
                      ]
                    ),
                  ),

                  SizedBox(height: 20),

                  // --- HEADER ---
                  Text("Welcome Back!", style: kTitleStyle),
                  SizedBox(height: 8),
                  Text("Akses layanan informasi akademik UTB", style: kSubtitleStyle),

                  SizedBox(height: 40),

                  // --- FORM INPUT ---
                  Align(alignment: Alignment.centerLeft, child: Text("NIM", style: TextStyle(color: Colors.white70, fontSize: 12))),
                  SizedBox(height: 8),
                  _buildGlassInput(
                    controller: _nimController,
                    icon: Icons.person_outline,
                    hint: "Masukkan NIM",
                  ),

                  SizedBox(height: 20),

                  Align(alignment: Alignment.centerLeft, child: Text("Password", style: TextStyle(color: Colors.white70, fontSize: 12))),
                  SizedBox(height: 8),
                  _buildGlassInput(
                    controller: _passController,
                    icon: Icons.lock_outline,
                    hint: "Masukkan Password",
                    isPassword: true,
                  ),

                  // Lupa Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text("Lupa Password?", style: TextStyle(color: kUtbBlue, fontSize: 12)),
                    ),
                  ),

                  SizedBox(height: 20),

                  // --- TOMBOL LOGIN ---
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF00C853)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kUtbGreen.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Sign in", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // --- LAYER 3: TOMBOL BACK ---
          Positioned(
            top: statusBarHeight + 5,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildGlowCircle(Color color) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.4),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kInputBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _isObscure : false,
        style: TextStyle(color: Colors.white),
        cursorColor: kUtbGreen,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[500]),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                )
              : null,
        ),
      ),
    );
  }
}