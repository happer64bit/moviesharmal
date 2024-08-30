import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moviesharmal/utils/db.dart';
import 'package:vibration/vibration.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> savedMovies = [];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    final movies = await dbHelper.getFavoriteMovies();
    setState(() {
      savedMovies = movies;
    });
  }

  void _removeFavoriteMovie(Map<String, dynamic> movie) async {
    await dbHelper.removeFavoriteMovie(movie[DatabaseHelper.columnMovieId]);
    
    if (await Vibration.hasAmplitudeControl() == true) {
    Vibration.vibrate(amplitude: 10);
    }


    final index = savedMovies.indexOf(movie);
    if (index != -1) {
      setState(() {
        savedMovies.removeAt(index);
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Movie has been removed from favorites.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await dbHelper.addFavoriteMovie(movie);
            setState(() {
              _fetchMovies();
            });
          },
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, Map<String, dynamic> movie) {
    return InkWell(
      onTap: () {
        // Handle tap if needed
      },
      onLongPress: () {
        _removeFavoriteMovie(movie);
        _fetchMovies();
      },
      child: Container(
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: "https://image.tmdb.org/t/p/original/${movie['backdrop_path']}",
                width: 120,
                height: 150,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                movie['title'] ?? 'No Title',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourite Movies"),
        leading: IconButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: savedMovies.length,
              itemBuilder: (context, index) {
                final movie = savedMovies[index];
                
                return _buildItem(context, movie);
              },
            ),
          ),
        ],
      ),
    );
  }
}
