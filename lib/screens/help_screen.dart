import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y Soporte', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Cómo podemos\nayudarte hoy?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildSectionTitle('Preguntas Frecuentes'),
            _buildFaqSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('¿Aún necesitas ayuda?'),
            _buildHelpSection(),
            const SizedBox(height: 32),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return const TextField(
      decoration: InputDecoration(
        hintText: 'Buscar ayuda (ej. reportar, mapa...)',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        filled: true,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Column(
      children: [
        _buildFaqItem('¿Cómo agrego un baño nuevo?', 'Para agregar una ubicación nueva, ve a la pantalla principal del mapa y presiona el botón "+" en la esquina inferior derecha. Sigue los pasos para completar la información.'),
        _buildFaqItem('¿Cómo reporto un baño sucio?', 'Selecciona el baño en el mapa, desplázate hacia abajo en la tarjeta de información y toca el botón "Reportar problema". Elige "Limpieza" y envía tu reporte.'),
        _buildFaqItem('¿La aplicación es gratuita?', 'Sí, nuestra aplicación es 100% gratuita gracias a nuestra comunidad que ayuda a mantener la información actualizada.'),
        TextButton(
          onPressed: () {},
          child: const Text('Ver todas las preguntas frecuentes'),
        ),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer),
        ),
      ],
    );
  }

  Widget _buildHelpSection() {
    return Column(
      children: [
        _buildHelpItem(Icons.bug_report, 'Reportar un error', 'Si algo no funciona correctamente', () {}),
        _buildHelpItem(Icons.mail, 'Contactar Soporte', 'Envíanos un correo electrónico', () {}),
        _buildHelpItem(Icons.help_center, 'Centro de Ayuda', 'Visita nuestro sitio web', () {}),
      ],
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Column(
        children: [
          Text(
            'Versión 2.4.0 (Build 1024)',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Privacidad', style: TextStyle(fontSize: 12, color: Colors.blue)),
              SizedBox(width: 8),
              Text('•', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(width: 8),
              Text('Términos y Condiciones', style: TextStyle(fontSize: 12, color: Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }
}
