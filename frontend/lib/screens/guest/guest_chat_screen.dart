import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class GuestChatScreen extends StatefulWidget {
  @override
  _GuestChatScreenState createState() => _GuestChatScreenState();
}

class _GuestChatScreenState extends State<GuestChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // State untuk menyimpan pesan
  List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  // URL API PythonAnywhere
  final String baseUrl = "https://donisettt.pythonanywhere.com";

  // Daftar pertanyaan cepat untuk tamu
  final List<String> _guestSuggestions = [
    "Info Pendaftaran",
    "Daftar Jurusan",
    "Biaya Kuliah",
    "Lokasi Kampus",
    "Beasiswa",
    "Kontak Admin"
  ];

  @override
  void initState() {
    super.initState();
    // Pesan pembuka otomatis
    _messages.add({
      "sender": "bot",
      "text": "Halo! Selamat datang di layanan informasi publik SmartUTB. Ada yang bisa saya bantu terkait pendaftaran atau info kampus?"
    });
  }

  /// Mengirim pesan ke API Flask dengan role 'guest'
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isTyping = true; // Tampilkan indikator loading
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": text,
          "role": "guest", // Role khusus tamu (akses data_public.json saja)
          "nim": ""
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add({"sender": "bot", "text": data['response']});
        });
      } else {
        _showError("Server sedang sibuk, coba lagi nanti.");
      }
    } catch (e) {
      _showError("Gagal terhubung ke server.");
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  void _showError(String msg) {
    setState(() {
      _messages.add({"sender": "bot", "text": "⚠️ $msg"});
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: kDarkBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: kUtbGreen.withOpacity(0.2),
              child: Icon(Icons.support_agent, color: kUtbGreen),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Layanan Publik", style: TextStyle(color: Colors.white, fontSize: 16)),
                Text("Online • Smart Assistant", style: TextStyle(color: kUtbGreen, fontSize: 12)),
              ],
            )
          ],
        ),
      ),

      // --- BODY ---
      body: Column(
        children: [
          // Area Chat
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 15),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? kUtbBlue : Color(0xFF1F2C34),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: isUser ? Radius.circular(16) : Radius.circular(0),
                        bottomRight: isUser ? Radius.circular(0) : Radius.circular(16),
                      ),
                    ),
                    child: Text(msg['text']!, style: TextStyle(color: Colors.white, height: 1.4)),
                  ),
                );
              },
            ),
          ),

          // Indikator Typing
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("SmartUTB sedang mengetik...", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            ),

          // --- SUGGESTION CHIPS (Baru) ---
          _buildGuestSuggestions(),

          // --- INPUT AREA ---
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
            color: kDarkBg,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFF253341),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Tanya info kampus...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _sendMessage(_controller.text),
                  child: CircleAvatar(
                    backgroundColor: kUtbBlue,
                    radius: 25,
                    child: Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper: Menampilkan tombol pertanyaan cepat
  Widget _buildGuestSuggestions() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _guestSuggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              backgroundColor: const Color(0xFF253341),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
              ),
              label: Text(
                _guestSuggestions[index],
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              onPressed: () => _sendMessage(_guestSuggestions[index]),
            ),
          );
        },
      ),
    );
  }
}