import 'package:moviesharmal/utils/types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateManagement {
  static Future<void> saveState(List<String> selectedFilters, int currentPage) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('selectedFilters', selectedFilters);
    prefs.setInt('currentPage', currentPage);
  }

  static Future<StateResult> restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    final filters = prefs.getStringList('selectedFilters') ?? [];
    final currentPage = prefs.getInt('currentPage') ?? 1;
    final category = buildCategoryQuery(filters.toSet());
    return StateResult(filters: filters, currentPage: currentPage, category: category);
  }

  static String? buildCategoryQuery(Set<String> filters) {
    final selectedIds = filters.map((filter) => categoryMap[filter]!).toSet().toList();
    return selectedIds.isEmpty ? null : selectedIds.join(',');
  }
}

class StateResult {
  final List<String> filters;
  final int currentPage;
  final String? category;

  StateResult({required this.filters, required this.currentPage, this.category});
}
