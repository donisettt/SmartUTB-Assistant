import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart'; 

// Import Komponen Modular
import 'chat_view.dart';
import 'history_view.dart';
import 'about_view.dart'; // Pastikan ini sudah di-import

class StudentChatScreen extends StatefulWidget {
  final String userName;
  final String userNim;

  const StudentChatScreen({
    Key? key, 
    required this.userName, 
    required this.userNim
  }) : super(key: key);

  @override
  _StudentChatScreenState createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen> {
  // ==============================
  // 1. STATE & VARIABLES
  // ==============================
  
  // Data Chat & History
  List<Map<String, String>> _currentMessages = [];
  List<dynamic> _historySessions = [];
  
  // State UI
  String _activeTab = "Chat"; // Tab aktif default
  String _currentSessionId = "";
  bool _isLoadingHistory = false;

  // Konfigurasi API
  final String baseUrl = "https://donisettt.pythonanywhere.com";

  @override
  void initState() {
    super.initState();
    _startNewChat(); // Inisialisasi sesi baru saat masuk
  }

  // ==============================
  // 2. LOGIC & API METHODS
  // ==============================

  /// Memulai sesi chat baru (kosongkan layar, buat Session ID baru)
  void _startNewChat() {
    setState(() {
      _currentMessages = [];
      _currentMessages.add({
        "sender": "bot",
        "text": "Halo ${widget.userName}! Ada yang bisa saya bantu terkait akademik?"
      });
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _activeTab = "Chat";
    });
  }

  /// Mengirim pesan ke API Flask
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Tampilkan pesan user segera (Optimistic UI)
    setState(() {
      _currentMessages.add({"sender": "user", "text": text});
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": text,
          "role": "mahasiswa", // Role mahasiswa untuk akses data akademik
          "nim": widget.userNim,
          "session_id": _currentSessionId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentMessages.add({"sender": "bot", "text": data['response']});
        });
      } else {
        _showBotError("Server sedang sibuk.");
      }
    } catch (e) {
      _showBotError("Gagal terhubung ke server.");
    }
  }

  /// Mengambil daftar riwayat sesi chat dari server
  Future<void> _fetchSessions() async {
    setState(() => _isLoadingHistory = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_sessions'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nim": widget.userNim}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _historySessions = data['data'];
        });
      }
    } catch (e) {
      print("Error fetch sessions: $e");
    } finally {
      setState(() => _isLoadingHistory = false);
    }
  }

  /// Memuat ulang sesi lama berdasarkan ID
  Future<void> _loadOldSession(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_chat_detail'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nim": widget.userNim, "session_id": sessionId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> rawMsg = data['data'];
        
        setState(() {
          // Konversi data JSON ke format List Map
          _currentMessages = rawMsg
              .map((m) => {"sender": m['sender'].toString(), "text": m['text'].toString()})
              .toList();
          _currentSessionId = sessionId;
          _activeTab = "Chat"; // Otomatis pindah ke tab chat
        });
      }
    } catch (e) {
      print("Error load session: $e");
    }
  }

  void _showBotError(String message) {
    setState(() {
      _currentMessages.add({"sender": "bot", "text": "⚠️ $message"});
    });
  }

  // ==============================
  // 3. UI BUILDER
  // ==============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      
      // Tombol Tambah Chat (Hanya muncul di tab Histori)
      floatingActionButton: _activeTab == "Histori"
          ? FloatingActionButton(
              onPressed: _startNewChat,
              backgroundColor: kUtbGreen,
              child: Icon(Icons.add_comment_rounded, color: Colors.white),
              tooltip: "Mulai Chat Baru",
            )
          : null,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Logo, Logout, Navigasi Tab)
            _buildHeader(),

            // Content Switcher (Chat vs History vs About)
            Expanded(
              // --- BAGIAN INI YANG DIUBAH ---
              child: _activeTab == "Chat"
                  ? ChatView(
                      messages: _currentMessages,
                      userName: widget.userName,
                      onSendMessage: _sendMessage,
                    )
                  : _activeTab == "Histori"
                      ? HistoryView(
                          sessions: _historySessions,
                          isLoading: _isLoadingHistory,
                          onSessionTap: _loadOldSession,
                        )
                      // Jika bukan Chat dan bukan Histori, berarti About
                      : const AboutView(), 
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Atas: Logo & Logout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("SmartUTB", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.redAccent),
                onPressed: () => Navigator.pop(context),
                tooltip: "Keluar",
              )
            ],
          ),
          SizedBox(height: 20),
          
          // Baris Bawah: Navigasi Tab
          Row(
            children: [
              _buildNavButton("Chat", icon: Icons.chat_bubble_outline),
              SizedBox(width: 10),
              _buildNavButton("Histori", icon: Icons.history),
              SizedBox(width: 10),
              // Tombol About (Setting diubah jadi About)
              _buildNavButton("About", icon: Icons.info_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String text, {required IconData icon}) {
    bool isActive = _activeTab == text;
    return GestureDetector(
      onTap: () {
        setState(() => _activeTab = text);
        if (text == "Histori") _fetchSessions();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFF1976D2) : Color(0xFF425466).withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(children: [
          Icon(icon, color: Colors.white, size: 18),
          SizedBox(width: 6),
          Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13))
        ]),
      ),
    );
  }
}