import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Última actualización: 15 de Octubre, 2023',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bienvenido a RestRoom Finder',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gracias por elegir nuestra aplicación para localizar servicios sanitarios públicos. Nuestra misión es facilitar el acceso a la higiene básica de manera confiable y simple. \n\nAl descargar, acceder o utilizar nuestra aplicación móvil, usted acepta estar legalmente vinculado por estos Términos y Condiciones. Por favor, léalos cuidadosamente antes de continuar.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  '1. Uso del Servicio',
                  'Nuestra aplicación actúa como un directorio comunitario. Proporcionamos información sobre la ubicación de baños públicos basada en datos oficiales y aportes de la comunidad. No garantizamos la disponibilidad inmediata, el funcionamiento o el estado de limpieza de las instalaciones en tiempo real. El uso de la información es bajo su propio riesgo.',
                ),
                _buildSection(
                  '2. Responsabilidad del Usuario',
                  'Usted se compromete a utilizar la plataforma de manera ética. Esto incluye no subir información falsa sobre ubicaciones y respetar las instalaciones públicas que visita. Cualquier reporte malintencionado o uso indebido de la plataforma para fines ajenos a su propósito resultará en la suspensión inmediata de su cuenta.',
                ),
                _buildSection(
                  '3. Privacidad y Geolocalización',
                  'Para proporcionarle los baños más cercanos, requerimos acceso a su ubicación precisa mientras usa la app. Estos datos de ubicación son anónimos y se utilizan únicamente para mejorar la precisión de nuestros mapas y servicios de navegación. Sus datos personales no serán vendidos ni compartidos con terceros sin su consentimiento explícito, salvo cuando sea requerido por ley.',
                ),
                _buildSection(
                  '4. Contenido de Terceros',
                  'La aplicación puede contener enlaces a sitios web o servicios de terceros (como mapas de navegación externos). No somos responsables del contenido, políticas de privacidad o prácticas de sitios web o servicios de terceros.',
                ),
                _buildSection(
                  '5. Modificaciones',
                  'Nos reservamos el derecho de modificar o reemplazar estos términos en cualquier momento. Si una revisión es significativa, intentaremos proporcionar un aviso con al menos 30 días de antelación antes de que los nuevos términos entren en vigor.',
                ),
                const SizedBox(height: 100), // Space for the floating button
              ],
            ),
          ),
          // Sticky Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Aceptar y Continuar'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Al continuar, confirma que ha leído y acepta nuestros términos de servicio.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
