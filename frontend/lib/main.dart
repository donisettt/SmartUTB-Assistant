import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      scaffoldBackgroundColor: Color(0xFFF5F5F5), // Warna background agak abu terang
      useMaterial3: true,
    ),
    home: ChatScreen(),
  ));
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  
  // Struktur Data: List of List. 
  // Kita menyimpan BANYAK sesi chat. Setiap sesi berisi BANYAK pesan.
  // Index 0 = Sesi paling baru.
  List<List<Map<String, String>>> _sessions = [];
  int _currentSessionIndex = 0;

  // URL Backend (Gunakan 10.0.2.2 untuk Emulator, atau localhost untuk Web)
  final String baseUrl = "http://10.0.2.2:5000"; 

  @override
  void initState() {
    super.initState();
    _createNewSession(); // Mulai dengan 1 sesi kosong
  }

  void _createNewSession() {
    setState(() {
      // Tambahkan sesi baru kosong di paling atas
      _sessions.insert(0, []); 
      _currentSessionIndex = 0; // Pindah fokus ke sesi baru ini
    });
    if (Navigator.canPop(context)) Navigator.pop(context); // Tutup sidebar jika terbuka
  }

  void _switchSession(int index) {
    setState(() {
      _currentSessionIndex = index;
    });
    Navigator.pop(context); // Tutup sidebar
  }

  // Mendapatkan judul sesi berdasarkan chat pertama (biar mirip AI beneran)
  String _getSessionTitle(int index) {
    if (_sessions[index].isEmpty) return "Percakapan Baru";
    String firstMsg = _sessions[index][0]['text'] ?? "Chat";
    if (firstMsg.length > 20) return firstMsg.substring(0, 20) + "...";
    return firstMsg;
  }

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;

    // Simpan pesan user ke sesi yang sedang aktif
    setState(() {
      _sessions[_currentSessionIndex].add({"sender": "user", "text": text});
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        setState(() {
          _sessions[_currentSessionIndex].add({"sender": "bot", "text": data['response']});
        });

        if (data['found'] == false) {
           _showTeachDialog(text);
        }
      }
    } catch (e) {
      setState(() {
        _sessions[_currentSessionIndex].add({"sender": "bot", "text": "Error: Cek koneksi backend."});
      });
    }
  }

  Future<void> _teachBot(String question, String answer) async {
    await http.post(
      Uri.parse('$baseUrl/teach'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"question": question, "answer": answer}),
    );
    setState(() {
        _sessions[_currentSessionIndex].add({"sender": "bot", "text": "Terima kasih! Saya sudah ingat."});
    });
  }

  void _showTeachDialog(String question) {
    TextEditingController answerController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ajari Saya"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Saya tidak tahu jawaban: \"$question\""),
            SizedBox(height: 10),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                labelText: "Jawaban yang benar",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _teachBot(question, answerController.text);
            },
            child: Text("Kirim"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil list pesan dari sesi yang sedang aktif
    final activeMessages = _sessions[_currentSessionIndex];

    return Scaffold(
      // AppBar Sederhana
      appBar: AppBar(
        title: Text(_getSessionTitle(_currentSessionIndex)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      
      // Sidebar (Drawer)
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey[900]),
              accountName: Text("Doni Wahyono"),
              accountEmail: Text("Mahasiswa Lulusan AI"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
              ),
            ),
            // Tombol New Chat
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.blueGrey[700],
                  foregroundColor: Colors.white,
                ),
                onPressed: _createNewSession,
                icon: Icon(Icons.add),
                label: Text("Percakapan Baru"),
              ),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _sessions.length,
                itemBuilder: (context, index) {
                  // Highlight sesi yang sedang aktif
                  bool isActive = index == _currentSessionIndex;
                  return ListTile(
                    tileColor: isActive ? Colors.blueGrey[100] : null,
                    leading: Icon(Icons.chat_bubble_outline),
                    title: Text(
                      _getSessionTitle(index),
                      style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                    ),
                    onTap: () => _switchSession(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Area Chat
      body: Column(
        children: [
          Expanded(
            child: activeMessages.isEmpty 
            ? Center(child: Text("Mulai chat baru dengan AI...", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: activeMessages.length,
              itemBuilder: (context, index) {
                final msg = activeMessages[index];
                final isUser = msg['sender'] == 'user';
                return Row(
                  mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Bot (Kiri)
                    if (!isUser) 
                      CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
                        radius: 16,
                      ),
                    if (!isUser) SizedBox(width: 8),

                    // Bubble Chat
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blueGrey[900] : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft: isUser ? Radius.circular(12) : Radius.circular(0),
                            bottomRight: isUser ? Radius.circular(0) : Radius.circular(12),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                          ]
                        ),
                        child: Text(
                          msg['text']!,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    // Icon User (Kanan)
                    if (isUser) SizedBox(width: 8),
                    if (isUser) 
                      CircleAvatar(
                        backgroundColor: Colors.blueGrey[700],
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                        radius: 16,
                      ),
                  ],
                );
              },
            ),
          ),
          
          // Input Area Modern
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      fillColor: Colors.grey[100],
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blueGrey[900],
                  radius: 24,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}