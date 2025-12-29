import 'package:flutter/material.dart';
import 'package:mkgo/screens/help_screen.dart';
import 'package:mkgo/screens/my_reviews_screen.dart';
import 'package:mkgo/screens/my_saved_bathrooms_screen.dart';
import 'package:mkgo/screens/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Profile Header
              const CircleAvatar(
                radius: 56,
                backgroundImage: NetworkImage('https://lh3.googleusercontent.com/a/ACg8ocK_gL6Zc7ojVu5t_Lifaq6P9C1NjVqa8UNQNGnWLKZDf7Lc=s96-c'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Juan Pérez',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Usuario desde 2023',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('12', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Reseñas', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 40, child: VerticalDivider()),
                  Column(
                    children: [
                      Text('5', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Fotos', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Actividad'),
              _buildActivitySection(context),
              const SizedBox(height: 24),
              _buildSectionTitle('General'),
              _buildGeneralSection(context),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Versión 1.0.4', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
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

  Widget _buildActivitySection(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildListTile(Icons.bookmark, 'Mis baños guardados', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MySavedBathroomsScreen()),
            );
          }),
          const Divider(height: 1),
          _buildListTile(Icons.star, 'Mis reseñas', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyReviewsScreen()),
            );
          }),
          const Divider(height: 1),
          _buildListTile(Icons.send, 'Reportes enviados', () {}),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildListTile(Icons.settings, 'Configuración', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }),
          const Divider(height: 1),
          _buildListTile(Icons.help, 'Ayuda y Soporte', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
