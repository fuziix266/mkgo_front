import 'package:flutter/material.dart';
import 'package:mkgo/screens/filters_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Placeholder
          Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.map,
                size: 100,
                color: Colors.grey,
              ),
            ),
          ),

          // Top Search Bar Area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 48, left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.0)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Find a restroom...',
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => const FiltersScreen(),
                                isScrollControlled: true,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundImage: NetworkImage('https://lh3.googleusercontent.com/a/ACg8ocK_gL6Zc7ojVu5t_Lifaq6P9C1NjVqa8UNQNGnWLKZDf7Lc=s96-c'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls Area
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {},
                  heroTag: 'location',
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  onPressed: () {},
                  heroTag: 'layers',
                  child: const Icon(Icons.layers),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  onPressed: () {},
                  heroTag: 'add',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Bottom Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Central Park Restroom',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 18),
                                Text('4.5 (120 reviews) • 200m away'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: Image(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAvh65XVuWIuQZMYRY20iF8uNK8pLOf3GT2BOQqd5HreAT2AJR-owrCd81u9hJpC_4fjr8UNeITE2oxifCKECFQnsDV8I9eJh1nzg-QvZeOCNkeQn7Wb-cXAEPhPp9i_7d633ASNus3tBQMHPjwwhd7NzabCbx98RLiUN1ULz9lueaf8HFnRktosQXPhjzCYQN93g3TJhCDtXuN_mYJWMB0kUw92ODSCVordGUoqW_bGRPModft0MgeyZyx404VOOk4Ho3MvIKYw1A'
                          ),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.directions),
                          label: const Text('Navigate'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.info),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
