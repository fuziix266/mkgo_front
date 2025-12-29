import 'package:flutter/material.dart';
import 'package:mkgo/screens/privacy_policy_screen.dart';
import 'package:mkgo/screens/terms_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(context),
            const SizedBox(height: 24),
            _buildSectionTitle('Preferencias'),
            _buildPreferencesSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Privacidad y Datos'),
            _buildPrivacySection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Información y Ayuda'),
            _buildInfoSection(context),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cerrar Sesión'),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'WC Finder App v1.0.2',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/a/ACg8ocK_gL6Zc7ojVu5t_Lifaq6P9C1NjVqa8UNQNGnWLKZDf7Lc=s96-c'),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usuario Demo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('usuario@ejemplo.com', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Editar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildSettingsTile(Icons.notifications, 'Notificaciones', Switch(value: true, onChanged: (val) {})),
          const Divider(height: 1),
          _buildSettingsTile(Icons.dark_mode, 'Tema Oscuro', Switch(value: false, onChanged: (val) {})),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildSettingsTile(Icons.location_on, 'Permisos de Ubicación', const Icon(Icons.chevron_right), onTap: () {}),
          const Divider(height: 1),
          _buildSettingsTile(Icons.security, 'Gestión de Datos', const Icon(Icons.chevron_right), onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildSettingsTile(Icons.help, 'Ayuda y Soporte', const Icon(Icons.chevron_right), onTap: () {}),
          const Divider(height: 1),
          _buildSettingsTile(Icons.description, 'Términos y Condiciones', const Icon(Icons.chevron_right), onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TermsScreen()),
            );
          }),
          const Divider(height: 1),
          _buildSettingsTile(Icons.policy, 'Política de Privacidad', const Icon(Icons.chevron_right), onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, Widget trailing, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
