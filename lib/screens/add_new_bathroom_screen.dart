import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AddNewBathroomScreen extends StatefulWidget {
  const AddNewBathroomScreen({super.key});

  @override
  State<AddNewBathroomScreen> createState() => _AddNewBathroomScreenState();
}

class _AddNewBathroomScreenState extends State<AddNewBathroomScreen> {
  LatLng _selectedLocation = LatLng(51.509364, -0.128928);
  final MapController _mapController = MapController();
  String _selectedAccessType = 'Público';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Baño', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Section
            SizedBox(
              height: 224,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: _selectedLocation,
                      zoom: 13.0,
                      onPositionChanged: (position, hasGesture) {
                        if (hasGesture) {
                          setState(() {
                            _selectedLocation = position.center!;
                          });
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),
                    ],
                  ),
                  const Center(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del lugar',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  _buildPlaceTypeDropdown(),
                  const SizedBox(height: 16),
                  _buildAccessTypeSelector(),
                  const SizedBox(height: 16),
                  _buildPriceInput(),
                  const SizedBox(height: 16),
                  _buildDirectionsInput(),
                  const SizedBox(height: 16),
                  _buildPhotoUpload(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.save),
          label: const Text('Guardar baño'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Tipo de lugar',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Restaurante / Cafetería', child: Text('Restaurante / Cafetería')),
        DropdownMenuItem(value: 'Gasolinera', child: Text('Gasolinera')),
        DropdownMenuItem(value: 'Centro Comercial', child: Text('Centro Comercial')),
        DropdownMenuItem(value: 'Parque Público', child: Text('Parque Público')),
        DropdownMenuItem(value: 'Estación de Transporte', child: Text('Estación de Transporte')),
        DropdownMenuItem(value: 'Otro', child: Text('Otro')),
      ],
      onChanged: (value) {},
    );
  }

  Widget _buildAccessTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Acceso', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAccessTypeOption(Icons.public, 'Público'),
            _buildAccessTypeOption(Icons.storefront, 'Clientes'),
            _buildAccessTypeOption(Icons.payments, 'De pago'),
          ],
        ),
      ],
    );
  }

  Widget _buildAccessTypeOption(IconData icon, String label) {
    final bool isSelected = _selectedAccessType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAccessType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInput() {
    return const TextField(
      decoration: InputDecoration(
        labelText: 'Precio (opcional)',
        prefixText: '\$',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildDirectionsInput() {
    return const TextField(
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Indicaciones',
        hintText: 'Ej. Segunda planta, pedir llave en caja...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, style: BorderStyle.dashed),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Colors.grey),
            SizedBox(height: 8),
            Text('Añadir una foto (opcional)', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
