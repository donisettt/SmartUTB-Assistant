import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';

class ChatView extends StatefulWidget {
  final List<Map<String, String>> messages;
  final String userName;
  final Function(String) onSendMessage;

  const ChatView({
    Key? key,
    required this.messages,
    required this.userName,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // ==============================
  // 1. STATE & CONTROLLERS
  // ==============================
  
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Daftar pertanyaan cepat (Suggestion Chips)
  final List<String> _suggestions = [
    "Berapa IPK saya?",
    "Jadwal Kuliah Hari Ini",
    "Syarat Cuti Akademik",
    "Kalender Akademik",
    "Info Beasiswa",
    "Kontak Dosen Wali"
  ];

  // ==============================
  // 2. LIFECYCLE & LOGIC
  // ==============================

  @override
  void didUpdateWidget(covariant ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika ada pesan baru, otomatis scroll ke bawah
    if (widget.messages.length > oldWidget.messages.length) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    widget.onSendMessage(text); // Kirim ke parent (StudentChatScreen)
    _inputController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ==============================
  // 3. UI BUILDER
  // ==============================

  @override
  Widget build(BuildContext context) {
    // Tampilkan Hero jika chat masih kosong atau baru sapaan awal
    bool isInitialState = widget.messages.length <= 1;

    return Column(
      children: [
        // A. Area Pesan (List atau Hero)
        Expanded(
          child: isInitialState ? _buildHeroContent() : _buildChatList(),
        ),

        // B. Suggestion Chips (Tombol Cepat)
        _buildSuggestionChips(),

        // C. Input Area (Kolom Ketik)
        _buildInputArea(),
      ],
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeroContent() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/robot.png'), 
                  fit: BoxFit.contain
                ),
                boxShadow: [
                  BoxShadow(
                    color: kUtbGreen.withOpacity(0.15), 
                    blurRadius: 40, 
                    offset: Offset(0, 10)
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Halo ${widget.userName},\nSilakan tanya sesuatu...",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16, 
                fontWeight: FontWeight.w600, 
                color: Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final msg = widget.messages[index];
        final isUser = msg['sender'] == 'user';
        
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(bottom: 15),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75
            ),
            decoration: BoxDecoration(
              color: isUser ? kUtbBlue : Color(0xFF1F2C34),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: isUser ? Radius.circular(16) : Radius.circular(0),
                bottomRight: isUser ? Radius.circular(0) : Radius.circular(16),
              ),
            ),
            child: Text(
              msg['text']!, 
              style: TextStyle(color: Colors.white, height: 1.4)
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionChips() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              backgroundColor: const Color(0xFF253341),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: kUtbGreen.withOpacity(0.5), width: 1),
              ),
              label: Text(
                _suggestions[index], 
                style: const TextStyle(color: Colors.white, fontSize: 12)
              ),
              onPressed: () => _handleSend(_suggestions[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
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
                borderRadius: BorderRadius.circular(30)
              ),
              child: TextField(
                controller: _inputController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Ketik pesan...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onSubmitted: _handleSend,
              ),
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: () => _handleSend(_inputController.text),
            child: CircleAvatar(
              backgroundColor: Color(0xFF1976D2),
              radius: 25,
              child: Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}