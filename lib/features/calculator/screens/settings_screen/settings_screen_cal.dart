import 'package:flutter/material.dart';

import '../../../../models/notifications.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Estado de los switches
  bool _darkMode = true;
  bool _notificationsEnabled = true;
  bool _aiSuggestions = true;
  bool _hapticFeedback = true;

  // Datos del perfil
  String _userName = "Usuario AI";
  String _userEmail = "usuario@calculatorai.com";
  String _avatarUrl = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkMode ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, _slideAnimation.value),
                end: Offset.zero,
              ).animate(_controller),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    _buildProfileSection(),
                    _buildSettingsSections(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // AppBar Personalizado
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      title: Text(
        'Configuración',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: _darkMode ? Colors.white : Colors.black,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: _darkMode ? Colors.white : Colors.black,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.save_outlined,
            color: _darkMode ? Colors.white : Colors.black,
          ),
          onPressed: _saveSettings,
        ),
      ],
    );
  }

  // Sección de Perfil con Foto
  SliverToBoxAdapter _buildProfileSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _editProfile,
          child: Container(
            decoration: BoxDecoration(
              color: _darkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar con animación
                Hero(
                  tag: 'profile-avatar',
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        _darkMode ? Colors.blueGrey[800] : Colors.blue[100],
                    backgroundImage:
                        _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                    child:
                        _avatarUrl.isEmpty
                            ? Icon(
                              Icons.person,
                              size: 30,
                              color:
                                  _darkMode ? Colors.white : Colors.blue[800],
                            )
                            : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _darkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              _darkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  color: _darkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Secciones de Configuración
  SliverList _buildSettingsSections() {
    return SliverList(
      delegate: SliverChildListDelegate([
        _buildSectionHeader('Preferencias de la Calculadora'),
        _buildSettingSwitch(
          title: 'Modo Oscuro',
          subtitle: 'Activar el tema oscuro',
          value: _darkMode,
          icon: Icons.dark_mode_outlined,
          onChanged: (val) => setState(() => _darkMode = val),
        ),
        _buildSettingSwitch(
          title: 'Sugerencias de IA',
          subtitle: 'Obtén sugerencias inteligentes',
          value: _aiSuggestions,
          icon: Icons.auto_awesome_outlined,
          onChanged: (val) => setState(() => _aiSuggestions = val),
        ),
        _buildSettingSwitch(
          title: 'Retroalimentación háptica',
          subtitle: 'Vibración al presionar botones',
          value: _hapticFeedback,
          icon: Icons.vibration_outlined,
          onChanged: (val) => setState(() => _hapticFeedback = val),
        ),
        _buildSectionHeader('Notificaciones'),
        _buildSettingSwitch(
          title: 'Notificaciones',
          subtitle: 'Activar/desactivar todas las notificaciones',
          value: _notificationsEnabled,
          icon: Icons.notifications_outlined,
          onChanged: (val) => setState(() => _notificationsEnabled = val),
        ),
        _buildSettingItem(
          title: 'Personalizar notificaciones',
          subtitle: 'Configura qué notificaciones recibir',
          icon: Icons.notification_add_outlined,
          onTap: _openNotificationSettings,
        ),
        _buildSectionHeader('Cuenta y Privacidad'),
        _buildSettingItem(
          title: 'Privacidad y seguridad',
          subtitle: 'Gestiona tus datos y privacidad',
          icon: Icons.security_outlined,
          onTap: _openPrivacySettings,
        ),
        _buildSettingItem(
          title: 'Cerrar sesión',
          subtitle: 'Salir de tu cuenta',
          icon: Icons.logout_outlined,
          onTap: _logout,
          isLogout: true,
        ),
        const SizedBox(height: 30),
        _buildAppInfo(),
      ]),
    );
  }

  // Componentes Reutilizables
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _darkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: _darkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: _darkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        secondary: Icon(
          icon,
          color: _darkMode ? Colors.blue[300] : Colors.blue,
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
        inactiveTrackColor: _darkMode ? Colors.grey[700] : Colors.grey[300],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Function() onTap,
    bool isLogout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color:
                isLogout
                    ? Colors.red
                    : (_darkMode ? Colors.white : Colors.black),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color:
                isLogout
                    ? Colors.red.withOpacity(0.7)
                    : (_darkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
        leading: Icon(
          icon,
          color:
              isLogout
                  ? Colors.red
                  : (_darkMode ? Colors.blue[300] : Colors.blue),
        ),
        trailing: Icon(
          Icons.chevron_right_outlined,
          color: _darkMode ? Colors.grey[500] : Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAppInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Calculator AI v1.0.0',
            style: TextStyle(
              color: _darkMode ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2023 AI Calculator Team',
            style: TextStyle(
              fontSize: 12,
              color: _darkMode ? Colors.grey[700] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Funcionalidades Adicionales

  void _editProfile() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            child: GestureDetector(
              onTap: () {},
              child: DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.5,
                maxChildSize: 0.9,
                builder: (_, controller) {
                  return Container(
                    decoration: BoxDecoration(
                      color: _darkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: _buildEditProfileForm(controller),
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _userName = result['name'] ?? _userName;
        _userEmail = result['email'] ?? _userEmail;
        _avatarUrl = result['avatarUrl'] ?? _avatarUrl;
      });
    }
  }

  Widget _buildEditProfileForm(ScrollController controller) {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: [
          const Icon(Icons.drag_handle, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Editar Perfil',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _darkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _changeAvatar,
            child: Stack(
              children: [
                Hero(
                  tag: 'profile-avatar',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        _darkMode ? Colors.blueGrey[800] : Colors.blue[100],
                    backgroundImage:
                        _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                    child:
                        _avatarUrl.isEmpty
                            ? Icon(
                              Icons.person,
                              size: 50,
                              color:
                                  _darkMode ? Colors.white : Colors.blue[800],
                            )
                            : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildProfileTextField(
            controller: nameController,
            label: 'Nombre',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildProfileTextField(
            controller: emailController,
            label: 'Correo electrónico',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'name': nameController.text,
                'email': emailController.text,
                'avatarUrl': _avatarUrl,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Guardar Cambios'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _changeAvatar() {
    // Aquí puedes implementar la lógica para cambiar el avatar (galería, cámara, etc.)
    // Por ahora solo muestra un snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de cambiar avatar no implementada'),
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Configuración guardada')));
  }

  void _openNotificationSettings() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder:
            (_, __, ___) => NotificationSettingsScreen(
              darkMode: _darkMode,
              notificationsEnabled: _notificationsEnabled,
            ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    ).then((result) {
      if (result != null) {
        setState(() => _notificationsEnabled = result);
      }
    });
  }

  void _openPrivacySettings() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Privacidad y seguridad')));
  }

  void _logout() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
  }
}
