import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import 'dart:convert';
import '../constants/constants.dart';

class FilterButtonWidget extends ConsumerWidget {
  final VoidCallback? onFilterApplied;
  final VoidCallback? onFilterReset;

  const FilterButtonWidget({
    Key? key,
    this.onFilterApplied,
    this.onFilterReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _showFilterBottomSheet(context, ref),
      child: const Icon(Icons.filter_list),
      tooltip: 'Filter',
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    final branches = jsonDecode(branchesJson) as List<dynamic>;
    final boards = jsonDecode(boardsJson) as List<dynamic>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        branches: branches,
        boards: boards,
        onFilterApplied: onFilterApplied,
        onFilterReset: onFilterReset,
      ),
    );
  }
}

class FilterBottomSheet extends ConsumerWidget {
  final List<dynamic> branches;
  final List<dynamic> boards;
  final VoidCallback? onFilterApplied;
  final VoidCallback? onFilterReset;

  const FilterBottomSheet({
    Key? key,
    required this.branches,
    required this.boards,
    this.onFilterApplied,
    this.onFilterReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterStateProvider);

    // Calculate available options based on current selections
    final availableBoards = filterState.branch != null
        ? boards
            .where((board) => (board['assignedBranches'] as List)
                .contains(filterState.branch))
            .toList()
        : [];

    final availableClasses = filterState.board != null
        ? (boards.firstWhere((board) => board['boardId'] == filterState.board,
                orElse: () => {'classes': []})['classes'] as List)
            .toList()
        : [];

    final availableSections =
        filterState.grade != null && filterState.branch != null
            ? (availableClasses.firstWhere(
                    (cls) => cls['classId'] == filterState.grade,
                    orElse: () => {'sections': []})['sections'] as List)
                .where((section) => section['branchId'] == filterState.branch)
                .toList()
            : [];

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    context: context,
                    ref: ref,
                    title: 'Branch',
                    items: branches,
                    valueKey: 'key',
                    displayKey: 'name',
                    selectedValue: filterState.branch,
                    onSelected: (value) => ref
                        .read(filterStateProvider.notifier)
                        .updateBranch(value),
                  ),
                  if (filterState.branch != null) ...[
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      context: context,
                      ref: ref,
                      title: 'Board',
                      items: availableBoards,
                      valueKey: 'boardId',
                      displayKey: 'boardName',
                      selectedValue: filterState.board,
                      onSelected: (value) => ref
                          .read(filterStateProvider.notifier)
                          .updateBoard(value),
                    ),
                  ],
                  if (filterState.board != null) ...[
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      context: context,
                      ref: ref,
                      title: 'Grade',
                      items: availableClasses,
                      valueKey: 'classId',
                      displayKey: 'className',
                      selectedValue: filterState.grade,
                      onSelected: (value) => ref
                          .read(filterStateProvider.notifier)
                          .updateGrade(value),
                    ),
                  ],
                  if (filterState.grade != null) ...[
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      context: context,
                      ref: ref,
                      title: 'Section',
                      items: availableSections,
                      valueKey: 'sectionId',
                      displayKey: 'sectionName',
                      selectedValues: filterState.section,
                      onSelected: (values) => ref
                          .read(filterStateProvider.notifier)
                          .updateSections(values),
                      isMultiSelect: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
          _buildActionButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filters',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildFilterSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required List<dynamic> items,
    required String valueKey,
    required String displayKey,
    String? selectedValue,
    List<String> selectedValues = const [],
    required Function(dynamic) onSelected,
    bool isMultiSelect = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Text(
            'No options available',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final value = item[valueKey].toString();
              final display = item[displayKey].toString();
              final isSelected = isMultiSelect
                  ? selectedValues.contains(value)
                  : selectedValue == value;

              return FilterChip(
                label: Text(
                  display,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) {
                  if (isMultiSelect) {
                    final newSelection = List<String>.from(selectedValues);
                    if (isSelected) {
                      newSelection.remove(value);
                    } else {
                      newSelection.add(value);
                    }
                    onSelected(newSelection);
                  } else {
                    onSelected(isSelected ? null : value);
                  }
                },
                selectedColor: Colors.blue.withOpacity(0.15),
                backgroundColor: Colors.grey.withOpacity(0.1),
                checkmarkColor: Colors.blue,
                elevation: 0,
                pressElevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              );
            }).toList(),
          ),
        if (isMultiSelect && items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'You can select multiple options',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterStateProvider);
    final hasActiveFilters = filterState.branch != null ||
        filterState.board != null ||
        filterState.grade != null ||
        filterState.section.isNotEmpty;

    return Column(
      children: [
        if (hasActiveFilters) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getActiveFiltersText(filterState),
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: hasActiveFilters
                    ? () => _showResetConfirmation(context, ref)
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: hasActiveFilters ? Colors.blue : Colors.grey,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 16,
                      color: hasActiveFilters ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reset',
                      style: TextStyle(
                        color: hasActiveFilters ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: hasActiveFilters
                    ? () {
                        if (onFilterApplied != null) {
                          onFilterApplied!();
                        }
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: hasActiveFilters ? 2 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check,
                      size: 16,
                      color: hasActiveFilters ? Colors.white : Colors.grey[300],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Apply',
                      style: TextStyle(
                        color:
                            hasActiveFilters ? Colors.white : Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  String _getActiveFiltersText(FilterState state) {
    final List<String> activeFilters = [];

    if (state.branch != null) activeFilters.add('Branch');
    if (state.board != null) activeFilters.add('Board');
    if (state.grade != null) activeFilters.add('Grade');
    if (state.section.isNotEmpty) {
      activeFilters.add(
          '${state.section.length} Section${state.section.length > 1 ? 's' : ''}');
    }

    if (activeFilters.isEmpty) return 'No filters applied';
    return 'Active filters: ${activeFilters.join(', ')}';
  }

  Future<void> _showResetConfirmation(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Filters'),
        content: const Text('Are you sure you want to reset all filters?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(filterStateProvider.notifier).resetFilters();
      if (onFilterReset != null) {
        onFilterReset!();
      }
      Navigator.pop(context);
    }
  }
}
