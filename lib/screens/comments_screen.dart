import 'package:flutter/material.dart';

class CommentsScreen extends StatelessWidget {
  const CommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildRestroomHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildCommentItem(
                  context,
                  name: 'Ana García',
                  time: '2h',
                  comment: 'Muy limpio, pero no había jabón hoy. Por lo demás, todo excelente. La rampa de acceso está en buen estado.',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDOkELjxtZI79MNgrEqD40TNNjZaRHaAeAyEO00m2qkiXjq51q6yguJzzJyIQXqU-hgqQ9o0JvWUsTK7HIGxMAoipEflOOGSIHMODlwAFhq0furAVAD-CkoPZ7_6tHnd5c4Zp2Wg4Lfx4rDON9MZEZsVuyBgwrVv6i92GYlooCFaaCZwdKfByro1Nl-mdQIfiQj-atpbh2ZsUjklMeOI3SNuA0mKtAsJVdKwldlO1G7kZAalJjv4wHQ4il67jl8CEiqd1RD1O8ueHA',
                  isReply: false,
                ),
                _buildCommentItem(
                  context,
                  name: 'Carlos Ruiz',
                  time: '1h',
                  comment: 'Gracias por el dato de la rampa, Ana! Justo iba a preguntar eso.',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCaiZFcJRK5-UqBkXjvdUGBoH_oWqcYPNWBhjhfNpFGYXScSark_Qybsi18rCW8QHsemTCHQVQ0DoFI6eQ-j_RQ6rlGtBlHcjn3WPDSqSu_Qw91CN09vIaaIR8_zIqQgrA5ijqCHvgJYamuMIiJLtrLymucvSiDPsb0yBVK1BJ-XKTU2Ph7Vgk5z6_KmbH_ygxaHEC5SPb24PK__emHi2jUgIbYOMtCZ3uFhpgscOKfb_Y6WrQOZvW0pvhgvL9xKQRqu-DGx-coKPk',
                  isReply: true,
                ),
                _buildCommentItem(
                  context,
                  name: 'Maria Rodríguez',
                  time: '5h',
                  comment: 'Cierran a las 8 PM, no vayan más tarde porque apagan las luces. De día es muy seguro.',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBARkqpefCEyEuWFhSf6WLuwfi5fky6Eez8qzDsGGM43vffY9SAJt12pjWdAnI32-xLu9QqHfwiVfDo5JaLP3jfiZ_bQd7jglHgpyJoa4EwB1rximbv3HaR4IMH8NIZVdZ6rLUMg3SHvyVVSJfhP10HTxMCCp_nisCsieq_b6o3ORqbAr229dAGlL4VCA_XvfhU5nPzXrOI2ZHo5b-PgqW8V75hjNZ2pxW3wP_MikIqpUyO1XwmyduTcQFvEm8b763Fv-SFPtN7ETE',
                  isReply: false,
                ),
              ],
            ),
          ),
          _buildCommentInput(context),
        ],
      ),
    );
  }

  Widget _buildRestroomHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Baños Park Central',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '4.5',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              const Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Icon(Icons.star_half, color: Colors.amber, size: 16),
                ],
              ),
              const SizedBox(width: 8),
              const Text('128 opiniones', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
    BuildContext context, {
    required String name,
    required String time,
    required String comment,
    required String imageUrl,
    required bool isReply,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: isReply ? 40.0 : 0.0, bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: isReply ? 16 : 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(comment, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Responder')),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Reportar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_a_photo)),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Comparte tu experiencia...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
