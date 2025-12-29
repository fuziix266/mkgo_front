import 'package:flutter/material.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Reseña'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres eliminar esta reseña?'),
                Text('Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Logic to delete the review
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reseñas', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter/Sort Tabs
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Todas', isSelected: true),
                _buildFilterChip('Recientes'),
                _buildFilterChip('Alta calificación'),
              ],
            ),
          ),
          // Review List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildReviewItem(
                  context,
                  'Baños Parque Central',
                  4.0,
                  '12 Oct',
                  'Muy limpio y tiene papel, pero la puerta no cierra bien. Sería bueno que arreglaran el cerrojo para mayor privacidad.',
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBGsoTukkMrFMzlLLCD4Io4BuBxzzES8-bUcJfTHVyuI42VAIdjDv1665thj0-0nSJRsP6ju_GrLoBPhTK6rC1W-QsMfG_zmev3Je0_kbeZNJSHeI66CFG5kvOGMYd-uZNEgdwVVKOi448qtgaaM5KFozg3d3PTfX2HL4CnXKGwNPIQaYSrPC0A_K3LV6SBhOIt0uqlZkXz2Nq0X_tXY9qNFUa-kS1BbNn2GmnD88lBsEl60W-rJzX6GpjzjRiQpFX0Nr4K3MHhzD8',
                ),
                _buildReviewItem(
                  context,
                  'Estación de Servicio Shell',
                  5.0,
                  '20 Sep',
                  'Excelente servicio, muy limpio y seguro. Siempre paro aquí cuando viajo al sur. Recomendado 100%.',
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCaKZHZTcV5sN_ble2DX4hfaVhrUlg2VbozwzWbi08Xg6HZ1KNcd_YLdVEyZKOSASo4b6e2qndpKpYkmEonB8y5-sldvPSPX9iVe4Rdpd4AFqDIZt8wPt8MGr3i2HvtcZGn_itWNLx6oUZ3ckI4DQgYE8nhEoq8WjyXzcKhrcNbF4hQ_TnViOXCbGu0bCF0YXDoXM7e2a7DwKECt0Md9993Vg5qfTNmsT7QDrh5S0L0v11bJts4FWPEfZAoTyhjBBl426YB8xa_2UE',
                ),
                _buildReviewItem(
                  context,
                  'Baños Plaza Mayor',
                  2.0,
                  '05 Ago',
                  'Falta limpieza y no había jabón. No lo recomiendo a menos que sea una emergencia.',
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDGfBNI0YVXFd6RHwoWzdFMBY5z6ChCyJhLFlqA-SiS0-QmzGMkqdXi6Ji-trFYZ-fnIrMZkWdNhUtbFtS9uEjLqB_SoXZsQ8VX__q9AmDo9jzsOpdwkMSD3wf0laP3rACYHHbxtVkkjMx-5C71EfYjxNRhBv_dGo8PfqYVxUZ7f3PZbdK4rrYUUphBszzRO372LaMQkwD2zrG9fLL1SMqxd-MHnwf4D7XEf327zQ3MLq875Sh_eK-2rKYpql5o4ybBEw5N4SK4Wgk',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {},
      ),
    );
  }

  Widget _buildReviewItem(
      BuildContext context, String title, double rating, String date, String review, String imageUrl) {
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(imageUrl,
                      width: 48, height: 48, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < rating.floor()
                                  ? Icons.star
                                  : index < rating ? Icons.star_half : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text(review, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Eliminar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
