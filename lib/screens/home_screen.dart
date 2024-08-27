import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:moviesharmal/utils/tmdb_api.dart' as tmdbapi;
import 'package:moviesharmal/utils/types.dart';

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
      _fetchMovies(category: _selectedFilters.join(','), page: nextPage);
    }
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
                                FilterChip(
                                  selected:
                                      _selectedFilters.contains("Happy"),
                                  onSelected: (value) {
                                    onFilterSelected("Happy", value);
                                  },
                                  label: const Text("Happy"),
                                ),
                                FilterChip(
                                  selected: _selectedFilters.contains("Sad"),
                                  onSelected: (value) {
                                    onFilterSelected("Sad", value);
                                  },
                                  label: const Text("Sad"),
                                ),
                                FilterChip(
                                  selected:
                                      _selectedFilters.contains("Lonely"),
                                  onSelected: (value) {
                                    onFilterSelected("Lonely", value);
                                  },
                                  label: const Text("Lonely"),
                                ),
                                FilterChip(
                                  selected: _selectedFilters
                                      .contains("Heart Broken"),
                                  onSelected: (value) {
                                    onFilterSelected("Heart Broken", value);
                                  },
                                  label: const Text("Heart Broken"),
                                ),
                                FilterChip(
                                  selected:
                                      _selectedFilters.contains("Romance"),
                                  onSelected: (value) {
                                    onFilterSelected("Romance", value);
                                  },
                                  label: const Text("Romance"),
                                ),
                                FilterChip(
                                  selected:
                                      _selectedFilters.contains("Adulty"),
                                  onSelected: (value) {
                                    onFilterSelected("Adulty", value);
                                  },
                                  label: const Text("Adulty"),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final category = _selectedFilters.join(',');
                                Navigator.pop(context);
                                _currentPage = 1; // Reset page number
                                _fetchMovies(category: category, page: 1); // Fetch movies with selected filters
                              },
                              child: const Text('Apply Filters'),
                            ),
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
                    color: const Color(0xff111318),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            "https://image.tmdb.org/t/p/original/${movie.backdropPath}",
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
