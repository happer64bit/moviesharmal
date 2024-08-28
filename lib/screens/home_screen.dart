import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:moviesharmal/utils/tmdb_api.dart' as tmdbapi;
import 'package:moviesharmal/utils/types.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> _selectedFilters = {};
  List<Movie> _movies = [];
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  final Map<String, List<int>> _genreMap = {
    "Happy": [35, 10402, 12, 28],
    "Sad": [18, 27, 10402],
    "Lonely": [9648, 99, 10752],
    "Heart Broken": [10749, 18, 27],
    "Romance": [10749, 18],
    "Adulty": [18, 10749],
  };

  Future<void> _fetchMovies({String? category, int page = 1}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final movies = await tmdbapi.fetchMovies(category: category, page: page);
      setState(() {
        if (page == 1) {
          _movies = movies;
        } else {
          _movies.addAll(movies);
        }
        _currentPage = page;
      });
    } catch (error) {
      print('Error fetching movies: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreMovies() async {
    if (!_isLoading) {
      final nextPage = _currentPage + 1;
      _fetchMovies(category: _buildCategoryQuery(), page: nextPage);
    }
  }

  String? _buildCategoryQuery() {
    final selectedIds = _selectedFilters
        .expand((filter) => _genreMap[filter]!)
        .toSet()
        .toList();
    return selectedIds.isEmpty ? null : selectedIds.join(',');
  }

  void _applyFilters() {
    setState(() {
      _movies = [];
    });
    _currentPage = 1;
    _fetchMovies(category: _buildCategoryQuery(), page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MovieSharMal"),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      void onFilterSelected(String filter, bool isSelected) {
                        setState(() {
                          if (isSelected) {
                            _selectedFilters.add(filter);
                          } else {
                            _selectedFilters.remove(filter);
                          }
                        });
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 10,
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            const Text(
                              "Filter Result",
                              style: TextStyle(fontSize: 24),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              runAlignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              alignment: WrapAlignment.start,
                              children: [
                                for (var filter in _genreMap.keys)
                                  FilterChip(
                                    selected: _selectedFilters.contains(filter),
                                    onSelected: (value) {
                                      onFilterSelected(filter, value);
                                    },
                                    label: Text(filter),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _applyFilters(); // Apply filters and fetch movies
                                },
                                child: const Text('Apply Filters'),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: _isLoading && _movies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Container(
        padding: const EdgeInsets.all(20.0),
        child: CardSwiper(
          cardsCount: _movies.length,
          cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
            final movie = _movies[index];
            return Container(
              color: Theme.of(context).brightness == Brightness.light ? const Color(0xfff9f9ff) : const Color(0xff111318),
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
                      placeholder: (context, url) => SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
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
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFc3c63d),
                          ),
                          child: const Text(
                            "Search On ChannelMyanmar",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          onEnd: () {
            _loadMoreMovies();
          },
        ),
      ),
    );
  }
}
