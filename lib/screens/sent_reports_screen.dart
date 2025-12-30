import 'package:flutter/material.dart';

class SentReportsScreen extends StatelessWidget {
  const SentReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes Enviados', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ReportCard(
            icon: Icons.wrong_location,
            iconColor: Colors.blue,
            title: 'Ubicación incorrecta',
            subtitle: 'Parque Central',
            date: '12 Oct 2023',
            status: 'En revisión',
            statusColor: Colors.amber,
          ),
          ReportCard(
            icon: Icons.cleaning_services,
            iconColor: Colors.orange,
            title: 'Baño sucio',
            subtitle: 'Estación de Tren',
            date: '05 Oct 2023',
            status: 'Resuelto',
            statusColor: Colors.green,
            userNote: '"No había papel y la puerta no cerraba correctamente."',
          ),
          ReportCard(
            icon: Icons.cancel,
            iconColor: Colors.red,
            title: 'Baño inexistente',
            subtitle: 'Plaza Mayor',
            date: '20 Sept 2023',
            status: 'Rechazado',
            statusColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String date;
  final String status;
  final Color statusColor;
  final String? userNote;

  const ReportCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.status,
    required this.statusColor,
    this.userNote,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withValues(alpha: 0.1),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(subtitle, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Chip(
                  label: Text(status, style: const TextStyle(fontSize: 10)),
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  labelStyle: TextStyle(color: statusColor),
                  side: BorderSide.none,
                ),
              ],
            ),
            if (userNote != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 52.0),
                child: Text(
                  userNote!,
                  style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
