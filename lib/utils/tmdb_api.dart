import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moviesharmal/config.dart';
import 'package:moviesharmal/utils/types.dart';

Future<List<Movie>> fetchMovies({String? category, int page = 1}) async {
  String genreQuery = '';
  if (category != null && category.isNotEmpty) {
    List<String> categories = category.split(',');
    List<String?> genreIds = categories
        .map((cat) => categoryMap[cat]?.toString())
        .where((id) => id != null)
        .toList();
    genreQuery = genreIds.isNotEmpty ? '&with_genres=${genreIds.join('|')}' : '';
  }

  final String url = 'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&page=$page$genreQuery';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final List<dynamic> results = json['results'];

    return results.map((data) => Movie.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load movies');
  }
}
