import 'package:flutter/material.dart';
import 'guest/guest_chat_screen.dart';
import 'student/student_chat_screen.dart';

class ChatScreen extends StatelessWidget {
  final bool isGuest;
  final String? userName;
  final String? userNim;

  ChatScreen({
    this.isGuest = true, 
    this.userName, 
    this.userNim
  });

  @override
  Widget build(BuildContext context) {
    // LOGIKA PEMISAH (SWITCHER)
    if (isGuest) {
      return GuestChatScreen();
    } else {
      return StudentChatScreen(
        userName: userName ?? 'Mahasiswa',
        userNim: userNim ?? '',
      );
    }
  }
}