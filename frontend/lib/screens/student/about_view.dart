import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants.dart';

class AboutView extends StatelessWidget {
  const AboutView({Key? key}) : super(key: key);

  // --- DATA DIRI ---
  final String _name = "Doni Setiawan Wahyono";
  final String _nim = "23552011146";
  final String _prodi = "Teknik Informatika";
  final String _campus = "Universitas Teknologi Bandung";

  // --- LINK SOSMED ---
  final String _githubUrl = "https://www.github.com/donisettt";
  final String _instaUrl = "https://www.instagram.com/dnisetyaw";
  final String _linkedinUrl = "https://www.linkedin.com/in/doni-setiawan-wahyono";

  // --- 2. FUNGSI MEMBUKA LINK ---
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint("Tidak bisa membuka link: $urlString");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // FOTO PROFIL
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kUtbGreen, width: 2),
              boxShadow: [
                BoxShadow(color: kUtbGreen.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
              ],
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF253341),
              backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/154044548?v=4"),
            ),
          ),
          
          const SizedBox(height: 24),

          // TEXT INFO
          Text(
            _name,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 22, 
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "$_nim • $_prodi",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            _campus,
            style: TextStyle(color: kUtbGreen, fontSize: 14, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 40),

          // KARTU DESKRIPSI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2C34),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tentang Aplikasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(
                  "SmartUTB adalah asisten akademik berbasis AI yang dirancang untuk membantu mahasiswa mendapatkan informasi perkuliahan secara real-time dan personal.",
                  style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- SOCIAL MEDIA SECTION ---
          const Text("Connect with me", style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 15),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Panggil Widget Helper dengan URL masing-masing
              _buildSocialBtn(Icons.code, "Github", _githubUrl, Colors.white),
              const SizedBox(width: 20),
              _buildSocialBtn(Icons.camera_alt, "Instagram", _instaUrl, const Color(0xFFE1306C)),
              const SizedBox(width: 20),
              _buildSocialBtn(Icons.work, "LinkedIn", _linkedinUrl, const Color(0xFF0077B5)),
            ],
          ),

          const SizedBox(height: 40),
          
          Text(
            "© 2025 SmartUTB Assistant v1.0",
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
          ),
        ],
      ),
    );
  }

  // --- 3. WIDGET TOMBOL SOSMED ---
  Widget _buildSocialBtn(IconData icon, String label, String url, Color color) {
    return Column(
      children: [
        // GestureDetector untuk mendeteksi Klik
        GestureDetector(
          onTap: () => _launchUrl(url),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF253341),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 3))
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10))
      ],
    );
  }
}