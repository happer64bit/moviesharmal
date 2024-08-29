import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:moviesharmal/utils/db.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/types.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class MovieCardSwiper extends StatefulWidget {
  final List<Movie> movies;
  final Future<void> Function() loadMoreMovies;
  final bool isLoading;

  const MovieCardSwiper({
    super.key,
    required this.movies,
    required this.loadMoreMovies,
    required this.isLoading,
  });

  @override
  _MovieCardSwiperState createState() => _MovieCardSwiperState();
}

class _MovieCardSwiperState extends State<MovieCardSwiper> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Set<int> _favoriteMovieIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavoriteMovies();
  }

  Future<void> _loadFavoriteMovies() async {
    final favoriteMovies = await _dbHelper.getFavoriteMovies();

    setState(() {
      _favoriteMovieIds = favoriteMovies.map((movie) => movie[DatabaseHelper.columnMovieId] as int).toSet();
    });
  }

  Future<void> _toggleFavorite(int movieId) async {
    final movie = widget.movies.firstWhere((m) => m.id == movieId);

    if (_favoriteMovieIds.contains(movieId)) {
      await _dbHelper.removeFavoriteMovie(movieId);
    } else {
      await _dbHelper.addFavoriteMovie({
        DatabaseHelper.columnMovieId: movieId,
        DatabaseHelper.columnType: 'movie',
        DatabaseHelper.columnTitle: movie.title,
        DatabaseHelper.columnBackdropPath: movie.backdropPath,
        DatabaseHelper.columnCreatedAt: DateTime.now().toIso8601String(),
      });
    }
    
    // Reload the favorite movies list to update the state
    await _loadFavoriteMovies();
  }

  @override
  Widget build(BuildContext context) {
    return CardSwiper(
      cardsCount: widget.movies.length,
      isLoop: false,
      cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
        final movie = widget.movies[index];
        final isFavorite = _favoriteMovieIds.contains(movie.id);

        return Container(
          height: MediaQuery.of(context).size.height,
          color: Theme.of(context).brightness == Brightness.light ? const Color(0xfff9f9ff) : const Color(0xff111318),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    imageUrl: "https://image.tmdb.org/t/p/original/${movie.backdropPath}",
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SelectionArea(
                  child: Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(movie.overview),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => _toggleFavorite(movie.id),
                      tooltip: isFavorite ? "Remove from favorites" : "Add to favorites",
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () async {
                        await launchUrl(Uri.parse("https://www.channelmyanmar.to/?s=${movie.title}"));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFc3c63d),
                        ),
                        child: const Text(
                          "Search On Channel Myanmar",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      onSwipe: (previousIndex, currentIndex, direction) {
        if ((currentIndex! + 1) == (widget.movies.length - 1) && !widget.isLoading) {
          widget.loadMoreMovies();
        }
        return true;
      },
    );
  }
}
