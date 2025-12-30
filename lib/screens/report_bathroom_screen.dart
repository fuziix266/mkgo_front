import 'package:flutter/material.dart';

class ReportBathroomScreen extends StatefulWidget {
  const ReportBathroomScreen({super.key});

  @override
  State<ReportBathroomScreen> createState() => _ReportBathroomScreenState();
}

class _ReportBathroomScreenState extends State<ReportBathroomScreen> {
  String? _selectedReason;
  final List<String> _reasons = ['No existe', 'Spam', 'Ubicación incorrecta', 'Contenido ofensivo'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Handle
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reportar este baño',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Ayúdanos a mantener la información actualizada.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Reason Selector
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: _reasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedReason = reason;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconForReason(reason),
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reason,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Details Input
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe el problema con más detalle...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const Spacer(),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.report),
              label: const Text('Enviar reporte'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.red,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForReason(String reason) {
    switch (reason) {
      case 'No existe':
        return Icons.visibility_off;
      case 'Spam':
        return Icons.campaign;
      case 'Ubicación incorrecta':
        return Icons.wrong_location;
      case 'Contenido ofensivo':
        return Icons.flag;
      default:
        return Icons.help;
    }
  }
}
