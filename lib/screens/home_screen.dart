import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moviesharmal/utils/state_management.dart';
import 'package:moviesharmal/utils/types.dart';
import 'package:moviesharmal/widgets/filter_bottom_sheet.dart';
import 'package:moviesharmal/widgets/movie_card.dart';
import 'package:moviesharmal/utils/tmdb_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _restoreState();
    _fetchMovies();
  }

  Future<void> _restoreState() async {
    final result = await StateManagement.restoreState();
    setState(() {
      _selectedFilters.addAll(result.filters);
      _currentPage = result.currentPage;
    });
    await _fetchMovies(category: result.category, page: result.currentPage);
  }

  Future<void> _fetchMovies({String? category, int page = 1}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final movies = await fetchMovies(category: category, page: page);
      setState(() {
        if (page == 1) {
          _movies = movies;
        } else {
          _movies.addAll(movies);
        }
        _currentPage = page;
      });
      await StateManagement.saveState(_selectedFilters.toList(), _currentPage);
    } catch (error) {
      print('Error fetching movies: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _movies = [];
      _currentPage = 1;
    });
    _fetchMovies(category: StateManagement.buildCategoryQuery(_selectedFilters), page: 1);
  }
  
  Future<void> _loadMoreMovies() async {
    if (!_isLoading) {
      final nextPage = _currentPage + 1;
      _fetchMovies(category: _buildCategoryQuery(), page: nextPage);
    }
  }

  String? _buildCategoryQuery([Set<String>? filters]) {
    final selectedIds = (filters ?? _selectedFilters)
        .map((filter) => categoryMap[filter]!)
        .toSet()
        .toList();
    return selectedIds.isEmpty ? null : selectedIds.join(',');
  }

  Future<void> _clearState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedFilters');
    await prefs.remove('currentPage');

    setState(() {
      _selectedFilters.clear();
      _movies.clear();
      _currentPage = 1;
    });

    // Optionally, you can fetch movies without any filters after clearing the state
    _fetchMovies(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MovieSharMal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => FilterBottomSheet(
                  selectedFilters: _selectedFilters,
                  applyFilters: _applyFilters,
                  clearState: _clearState,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              GoRouter.of(context).push("/favourite");
            },
          )
        ],
      ),
      body: _isLoading && _movies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : MovieCardSwiper(
              movies: _movies,
              loadMoreMovies: _loadMoreMovies,
              isLoading: _isLoading,
            ),
    );
  }
}
