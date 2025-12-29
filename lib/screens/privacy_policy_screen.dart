import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Políticas de Privacidad', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Última actualización: 10 de Octubre, 2023',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Introducción',
              'Bienvenido a nuestra aplicación. Su privacidad es importante para nosotros. Esta política explica cómo recopilamos, usamos y protegemos su información cuando utiliza nuestra aplicación para encontrar baños públicos de manera rápida y confiable.',
            ),
            _buildSection(
              '2. Recolección de Datos',
              'Para brindarle el servicio principal de nuestra aplicación, recopilamos los siguientes datos:',
              children: [
                _buildListItem(Icons.location_on, 'Ubicación Precisa', 'Utilizamos su GPS únicamente mientras la app está en uso para mostrarle los baños cercanos. No rastreamos su ubicación en segundo plano.'),
                _buildListItem(Icons.bar_chart, 'Datos de Uso Anónimos', 'Recopilamos estadísticas generales para mejorar el rendimiento y la estabilidad de la aplicación.'),
              ],
            ),
            _buildSection(
              '3. Uso de la Información',
              'Utilizamos la información recopilada exclusivamente para mejorar su experiencia: calcular rutas óptimas, verificar la disponibilidad de los servicios sanitarios y mantener la precisión de nuestra base de datos.',
            ),
            _buildSection(
              '4. Compartir Información',
              'No vendemos sus datos personales. Compartimos datos de ubicación anónimos con proveedores de mapas de confianza (como Google Maps o Mapbox) únicamente para renderizar el mapa en su dispositivo.',
            ),
            _buildSection(
              '5. Seguridad',
              'Implementamos medidas técnicas y organizativas para proteger su información personal contra pérdida, robo y uso no autorizado. Su confianza es nuestra prioridad.',
            ),
            _buildSection(
              '6. Contacto',
              'Si tiene alguna duda sobre nuestras políticas, por favor contáctenos:',
              children: [
                ListTile(
                  leading: const Icon(Icons.mail),
                  title: const Text('privacidad@bañoscercanos.app'),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, {List<Widget> children = const []}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: Colors.grey)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
