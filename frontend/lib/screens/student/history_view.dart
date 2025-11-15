import 'package:flutter/material.dart';
import '../../constants.dart'; 

class HistoryView extends StatelessWidget {
  final List<dynamic> sessions;
  final bool isLoading;
  final Function(String) onSessionTap;

  const HistoryView({
    Key? key,
    required this.sessions,
    required this.isLoading,
    required this.onSessionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // State 1: Loading
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: kUtbGreen));
    }
    
    // State 2: Data Kosong
    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada riwayat chat", 
          style: TextStyle(color: Colors.grey)
        ),
      );
    }

    // State 3: Menampilkan Data
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        return _buildHistoryItem(sessions[index]);
      },
    );
  }

  /// Widget untuk merender satu baris item riwayat chat
  Widget _buildHistoryItem(dynamic sessionData) {
    // Pastikan data aman (fallback ke string kosong jika null)
    final title = sessionData['title'] ?? 'Tanpa Judul';
    final date = sessionData['date'] ?? '-';
    final id = sessionData['id'] ?? '';

    return GestureDetector(
      onTap: () => onSessionTap(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2C34),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // Ikon Chat
            CircleAvatar(
              backgroundColor: kUtbGreen.withOpacity(0.2),
              radius: 20,
              child: Icon(Icons.chat, color: kUtbGreen, size: 18),
            ),
            const SizedBox(width: 15),
            
            // Info Judul & Tanggal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date, 
                    style: const TextStyle(color: Colors.grey, fontSize: 11)
                  ),
                ],
              ),
            ),
            
            // Panah Kanan
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }
}