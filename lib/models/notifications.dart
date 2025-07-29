import 'package:flutter/material.dart';
class NotificationSettingsScreen extends StatelessWidget {
  final bool darkMode;
  final bool notificationsEnabled;

  const NotificationSettingsScreen({
    super.key,
    required this.darkMode,
    required this.notificationsEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkMode ? Colors.white : Colors.black),
        title: Text(
          'Notificaciones',
          style: TextStyle(color: darkMode ? Colors.white : Colors.black),
        ),
      ),
      body: Center(
        child: Text(
          'Aquí puedes personalizar tus notificaciones',
          style: TextStyle(color: darkMode ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
