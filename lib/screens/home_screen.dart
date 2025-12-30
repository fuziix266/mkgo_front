import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mkgo/screens/bathroom_details_screen.dart';
import 'package:mkgo/screens/filters_screen.dart';

class Restroom {
  final String name;
  final String address;
  final LatLng location;
  final double rating;
  final int reviews;
  final String distance;
  final String image;

  Restroom({
    required this.name,
    required this.address,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.image,
  });
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onProfileTap;
  const HomeScreen({super.key, required this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng _currentCenter = LatLng(51.509364, -0.128928); // Default to London
  Restroom? _selectedRestroom;
  final TextEditingController _searchController = TextEditingController();
  List<Restroom> _filteredRestrooms = [];

  final List<Restroom> _restrooms = [
    Restroom(
      name: 'Central Park Restroom',
      address: 'Central Park, New York',
      location: LatLng(40.785091, -73.968285),
      rating: 4.5,
      reviews: 120,
      distance: '200m away',
      image:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAvh65XVuWIuQZMYRY20iF8uNK8pLOf3GT2BOQqd5HreAT2AJR-owrCd81u9hJpC_4fjr8UNeITE2oxifCKECFQnsDV8I9eJh1nzg-QvZeOCNkeQn7Wb-cXAEPhPp9i_7d633ASNus3tBQMHPjwwhd7NzabCbx98RLiUN1ULz9lueaf8HFnRktosQXPhjzCYQN93g3TJhCDtXuN_mYJWMB0kUw92ODSCVordGUoqW_bGRPModft0MgeyZyx404VOOk4Ho3MvIKYw1A',
    ),
    Restroom(
      name: 'Times Square Restroom',
      address: 'Times Square, New York',
      location: LatLng(40.7580, -73.9855),
      rating: 4.0,
      reviews: 250,
      distance: '1.5km away',
      image:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAvh65XVuWIuQZMYRY20iF8uNK8pLOf3GT2BOQqd5HreAT2AJR-owrCd81u9hJpC_4fjr8UNeITE2oxifCKECFQnsDV8I9eJh1nzg-QvZeOCNkeQn7Wb-cXAEPhPp9i_7d633ASNus3tBQMHPjwwhd7NzabCbx98RLiUN1ULz9lueaf8HFnRktosQXPhjzCYQN93g3TJhCDtXuN_mYJWMB0kUw92ODSCVordGUoqW_bGRPModft0MgeyZyx404VOOk4Ho3MvIKYw1A',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredRestrooms = _restrooms;
    _searchController.addListener(_filterRestrooms);
    _determinePosition();
  }

  void _filterRestrooms() {
    setState(() {
      _filteredRestrooms = _restrooms
          .where((restroom) => restroom.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentCenter = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            options: MapOptions(
              center: _currentCenter,
              zoom: 10.0,
              onTap: (_, __) {
                setState(() {
                  _selectedRestroom = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _filteredRestrooms.map((restroom) {
                  return Marker(
                    width: 80.0,
                    height: 80.0,
                    point: restroom.location,
                    builder: (ctx) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRestroom = restroom;
                        });
                      },
                      child: Container(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
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
                    Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    Theme.of(context).colorScheme.surface.withOpacity(0.0)
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Find a restroom...',
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
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
                  GestureDetector(
                    onTap: widget.onProfileTap,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        backgroundImage: NetworkImage('https://lh3.googleusercontent.com/a/ACg8ocK_gL6Zc7ojVu5t_Lifaq6P9C1NjVqa8UNQNGnWLKZDf7Lc=s96-c'),
                      ),
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
          if (_selectedRestroom != null)
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
                      color: Colors.black.withOpacity(0.15),
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedRestroom!.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 18),
                                  Text(
                                      '${_selectedRestroom!.rating} (${_selectedRestroom!.reviews} reviews) • ${_selectedRestroom!.distance}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: Image(
                            image: NetworkImage(_selectedRestroom!.image),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const BathroomDetailsScreen()),
                            );
                          },
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
