import 'package:flutter/material.dart';
import 'package:mkgo/screens/add_new_bathroom_screen.dart';

class MySavedBathroomsScreen extends StatelessWidget {
  const MySavedBathroomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Baños', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar en mis baños...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
            ),
          ),
          // Bathroom List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildBathroomItem(
                  context,
                  'Baño Parque Central',
                  '0.5 km',
                  4.5,
                  ['Gratis', 'Acceso', 'Abierto'],
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBKqC8sR2ehUH43LlcRHjmv1bNhtjMwk6-mrIiSSG87_Nev1a4aqhi6if03nNnSd-75wf_KhZL7mIYQVz4HsKRougnoRSI_9mI3pFI2uwYsEptcL45DXgYJswklKwJcHjOPRG31pxP2QNzxqVnkhuqy0UGHvtehtK04vBnC50XxsqJLy_H_d8C5DCONkD8hPwyU0NWAzWr_6YgXRLXc8XJN-o8ofSDx9k44IKTHGii5oBo4pVdT6VEfCk_iCLubBFVxg2bN3_U7CC0',
                ),
                _buildBathroomItem(
                  context,
                  'Estación de Bus Norte',
                  '2.1 km',
                  3.0,
                  ['\$0.50', 'Cerrado'],
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCr2pHh7g6KTQO8XxYCu6f93hNt193aGyMOJVFsFQKVFrwixEujZNYCYYvfNC0b4ZIWUisuyRT4f-o_TqiNJ_IQWSlrvZDIQLkuP6BdsuvV9QHx7lic8XKfgrfh_Aa306mmIHqioCqBLLrwZJKndGLFEcqw9eQ7H3xUdUBPnCI28DT1w4qPrZeOhyjw5pa4vU8QOkQBfYvMzlqAlT-VDwS-oRpUOq3z1piK08nxUSQyhsCOamdRTwpbiA9Wua1ofbxgWZplCa5bJ4Q',
                ),
                _buildBathroomItem(
                  context,
                  'Mercado Central',
                  '1.2 km',
                  5.0,
                  ['Gratis', 'Abierto'],
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAdu0vueXjmEDNBPj-0EdZ2zrdD9ntWOyHvuLFo2McCipqnghEjGTP5hqfYP-fsFFJLJojxi6hhko0PxGbKHoGYQHwnGLb6c5hHxl6Oh4vJFtfMTNGayaR2OKFaicbLcua5kgXMETfKem_AI1EPt87RYwAolaLFkuVIR-ZbBzDR7ITw_woZoqOEE_0EaJvq2pnTmcMeFKpgsRYxK0zjjC5o5z2YF5lPZrldxv1TqVG9KID_OFjwxNBzCi9EM-RNgHGXQFIEYXo4IJA',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNewBathroomScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBathroomItem(
      BuildContext context, String title, String distance, double rating, List<String> tags, String imageUrl) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(imageUrl,
                  width: 88, height: 88, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(distance, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: tags.map((tag) => Chip(label: Text(tag, style: const TextStyle(fontSize: 10)))).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
