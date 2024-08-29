import 'package:flutter/material.dart';
import 'package:moviesharmal/utils/types.dart';

class FilterBottomSheet extends StatefulWidget {
  final Set<String> selectedFilters;
  final VoidCallback applyFilters;
  final VoidCallback clearState;

  const FilterBottomSheet({
    super.key,
    required this.selectedFilters,
    required this.applyFilters,
    required this.clearState,
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Set<String> _localSelectedFilters;

  @override
  void initState() {
    super.initState();
    _localSelectedFilters = Set.from(widget.selectedFilters);
  }

  void _onFilterSelected(String filter, bool isSelected) {
    setState(() {
      if (isSelected) {
        _localSelectedFilters.add(filter);
      } else {
        _localSelectedFilters.remove(filter);
      }
    });
  }

  @override
    Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          const Text(
            "Filter Results",
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var filter in categoryMap.keys)
                FilterChip(
                  selected: _localSelectedFilters.contains(filter),
                  onSelected: (value) {
                    _onFilterSelected(filter, value);
                  },
                  label: Text(filter),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                widget.selectedFilters.clear();
                widget.selectedFilters.addAll(_localSelectedFilters);
                widget.applyFilters();
              },
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextButton(
              onPressed: () {
                widget.clearState();
                Navigator.pop(context);
              },
              child: const Text('Clear States'),
            ),
          ),
        ],
      ),
    );
  }
}
