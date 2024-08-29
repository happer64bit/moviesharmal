import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/types.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class MovieCardSwiper extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return CardSwiper(
      cardsCount: movies.length,
      isLoop: false,
      cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
        final movie = movies[index];
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
        if ((currentIndex! + 1) == (movies.length - 1) && !isLoading) {
          loadMoreMovies();
        }
        return true;
      },
    );
  }
}
