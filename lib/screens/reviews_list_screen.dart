import 'package:flutter/material.dart';
import 'package:mkgo/screens/add_review_screen.dart';

class ReviewsListScreen extends StatelessWidget {
  const ReviewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('Reseñas', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Parque Central', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text('4.5', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                Icon(Icons.star, color: Theme.of(context).primaryColor, size: 16),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReviewItem(
            context,
            'Ana García',
            'Hace 2 días',
            5.0,
            'Muy limpio y seguro. Tenía papel y jabón, lo cual es raro encontrar en baños públicos de esta zona.',
            'https://lh3.googleusercontent.com/a/ACg8ocK_gL6Zc7ojVu5t_Lifaq6P9C1NjVqa8UNQNGnWLKZDf7Lc=s96-c',
            isVerified: true,
          ),
          _buildReviewItem(
            context,
            'Carlos Mendez',
            'Hace 1 semana',
            4.0,
            'Bastante bien, pero el secador de manos no funcionaba. Al menos estaba limpio.',
            'https://lh3.googleusercontent.com/a/ACg8ocK_gL6Zc7ojVu5t_Lifaq6P9C1NjVqa8UNQNGnWLKZDf7Lc=s96-c',
          ),
          _buildReviewItem(
            context,
            'Tú',
            'Hace 1 mes',
            3.0,
            'Un poco descuidado y faltaba jabón. Espero que mejoren el mantenimiento.',
            'https://lh3.googleusercontent.com/a/ACg8ocK_gL6Zc7ojVu5t_Lifaq6P9C1NjVqa8UNQNGnWLKZDf7Lc=s96-c',
            isMyReview: true,
          ),
          _buildReviewItem(
            context,
            'Sofia Ruiz',
            'Hace 2 meses',
            1.0,
            'Sucio y sin luz. No lo recomiendo para nada.',
            'https://lh3.googleusercontent.com/a/ACg8ocK_gL6Zc7ojVu5t_Lifaq6P9C1NjVqa8UNQNGnWLKZDf7Lc=s96-c',
            isFaded: true,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const AddReviewScreen(),
            isScrollControlled: true,
          );
        },
        label: const Text('Escribir mi reseña'),
        icon: const Icon(Icons.edit_square),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildReviewItem(
    BuildContext context,
    String name,
    String date,
    double rating,
    String review,
    String imageUrl, {
    bool isVerified = false,
    bool isMyReview = false,
    bool isFaded = false,
  }) {
    return Opacity(
      opacity: isFaded ? 0.6 : 1.0,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isMyReview ? BorderSide(color: Theme.of(context).primaryColor) : BorderSide.none,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (isVerified) const Icon(Icons.verified, color: Colors.blue, size: 16),
                            if (isMyReview)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Chip(
                                  label: const Text('Tu reseña', style: TextStyle(fontSize: 10)),
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                ),
                              ),
                          ],
                        ),
                        Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_horiz),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.floor() ? Icons.star : (index < rating ? Icons.star_half : Icons.star_border),
                    color: Colors.amber,
                    size: 22,
                  );
                }),
              ),
              const SizedBox(height: 12),
              Text(review, style: const TextStyle(color: Colors.grey)),
              const Divider(height: 24),
              if (isMyReview)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('Editar')),
                    TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.delete),
                        label: const Text('Eliminar'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red)),
                  ],
                )
              else
                Row(
                  children: [
                    TextButton.icon(onPressed: () {}, icon: const Icon(Icons.thumb_up), label: const Text('Util')),
                    const SizedBox(width: 16),
                    TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.flag),
                        label: const Text('Reportar'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
