import 'package:flutter/material.dart';
import 'package:mkgo/screens/add_review_screen.dart';
import 'package:mkgo/screens/report_bathroom_screen.dart';
import 'package:mkgo/screens/reviews_list_screen.dart';

class BathroomDetailsScreen extends StatelessWidget {
  const BathroomDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildMaintenanceAlert(),
                  const SizedBox(height: 16),
                  _buildTags(),
                  const SizedBox(height: 24),
                  _buildRatingSummary(context),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                  const SizedBox(height: 24),
                  _buildVerificationCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 288.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: PageView(
          children: [
            _buildCarouselImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCC3DseUkQxLvJCvzuXrAWh1rws2vwrKqvHkpI0NMouNCKFCcI5iqmsBuP4BAcdWncIU-yTxkomPgEBfO-xEL4pYy7OjkxXPRUPTfUgrOBvx44KoXEOG3vPiUDHcOCe_Ed_zr5E3hK6uZYKouO9e3FA4wIcW9zPJLbpRtp76xT32LXcEqGWeJwD8AGuWQUc_1TCFYl5y6ZZX-ovWigJYWSVkASyeuftdiGSv89mKPlLtIdjtyaYPJQbsw-Xhc3hg2FWke9nD-Lhezc'),
            _buildCarouselImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCr3z3KfqpMGdWepGUlSyPm7rIZjPOrDVw71jdJpJPaw2lr43qYUpRyJhVm_rDud23-hmUXTCN5_18vvpCg24GnX4Z0ggKoxo594yRDwiw5Eq_kRW_VoPz5F1pjvOJH953aEzlIfIAAD43sAXODq4lFNDIbQA_FUc6ssw3vQyKxvR2y6wUjI8cu4e1NlvR5aZJZKaLG1TH_16BAqHu1yFwQoeSDasE0wNo2olx39DSpfW8RIuTh_RsGUpcErqti-n1qyTnqhivlDm4'),
            _buildCarouselImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAZ2B_v4Wzs-kC1Ct2o0grsMvwSVqraMhRbQ9p-T1HVsJ4Rv3RDSLwLbp4okUkxU6ivq_RKlf94hYoTobHD-SRgME2lDIYRrMMLPj--o9W6AER26aTetzuiexqiYjf4bAVMM-TUL50tuUg0K6Kl_elvVSJkwLol6aiHLvAyEkTQ14vT-CnpCbwD-QBtcfpmAKKpjsG0bAQfEn22aQc_mhnO5kdFmbFoeH6OMSrjmWxmMO8e49OAm6kIDkXXALISkMb1UfjhEcyIhWU'),
          ],
        ),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
      ],
    );
  }

  Widget _buildCarouselImage(String imageUrl) {
    return Image.network(imageUrl, fit: BoxFit.cover);
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Baños Parque Central',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.near_me, size: 16, color: Colors.green),
            SizedBox(width: 4),
            Text('120m', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Text('•'),
            SizedBox(width: 8),
            Text('Caminando'),
            SizedBox(width: 8),
            Text('•'),
            SizedBox(width: 8),
            Text('Av. Reforma 234'),
          ],
        ),
      ],
    );
  }

  Widget _buildMaintenanceAlert() {
    return Card(
      color: Colors.amber[50],
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.amber[200]!),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.construction, color: Colors.amber),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('En mantenimiento temporal', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('El área de lavamanos está siendo reparada. Los sanitarios siguen funcionando.', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTag('Gratis', Colors.green),
        _buildTag('Acceso público', Colors.blue),
        _buildTag('Accesible', Colors.grey, icon: Icons.accessible),
        _buildTag('Abierto ahora', Colors.teal),
      ],
    );
  }

  Widget _buildTag(String label, Color color, {IconData? icon}) {
    return Chip(
      avatar: icon != null ? Icon(icon, size: 16) : null,
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: color),
      side: BorderSide.none,
    );
  }

  Widget _buildRatingSummary(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('4.2', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Text('Basado en 85 reseñas'),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReviewsListScreen()),
                );
              },
              child: const Text('Ver todas'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3,
      children: [
        ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.directions), label: const Text('Cómo llegar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue)),
        ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const AddReviewScreen(),
                isScrollControlled: true,
              );
            },
            icon: const Icon(Icons.rate_review),
            label: const Text('Reseñar')),
        ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.chat_bubble), label: const Text('Comentar')),
        ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add_a_photo), label: const Text('Subir foto')),
        ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const ReportBathroomScreen(),
                isScrollControlled: true,
              );
            },
            icon: const Icon(Icons.flag),
            label: const Text('Reportar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100], foregroundColor: Colors.red)),
      ],
    );
  }

  Widget _buildVerificationCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Este baño existe?', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Ayuda a la comunidad a mantener la información actualizada.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Sí, existe'))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('No'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
