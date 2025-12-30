import 'package:flutter/material.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  double _rating = 4.0;
  bool _isOpenNow = true;
  bool _includeMaintenance = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle and Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Spacer
                  const Text('Filtros', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  // Price Section
                  _buildSectionTitle('Precio'),
                  _buildSegmentedControl(['Gratis', 'Pagado', 'Ambos']),
                  const SizedBox(height: 28),

                  // Access Section
                  _buildSectionTitle('Acceso'),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildFilterChip('Público'),
                      _buildFilterChip('Solo clientes'),
                      _buildFilterChip('Ambos', isSelected: true),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Rating Slider
                  _buildSectionTitle('Rating mínimo'),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _rating,
                          min: 1,
                          max: 5,
                          divisions: 8,
                          onChanged: (value) {
                            setState(() {
                              _rating = value;
                            });
                          },
                        ),
                      ),
                      Text(_rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Status Switches
                  _buildSectionTitle('Estado'),
                  _buildSwitchTile(Icons.meeting_room, 'Abierto ahora', _isOpenNow, (value) {
                    setState(() {
                      _isOpenNow = value;
                    });
                  }),
                  _buildSwitchTile(Icons.cleaning_services, 'Incluye mantenimiento', _includeMaintenance, (value) {
                    setState(() {
                      _includeMaintenance = value;
                    });
                  }),
                ],
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSegmentedControl(List<String> options) {
    // A simple implementation of a segmented control
    return Row(
      children: options.map((option) {
        return Expanded(
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: options.indexOf(option) == 0 ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
            ),
            child: Text(option),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Aplicar filtros'),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}
