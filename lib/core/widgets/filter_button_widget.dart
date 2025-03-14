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
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
          ),
          _buildActionButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.close,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Text(
            'No options available',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
              fontSize: 14,
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
                    color: isSelected ? Colors.blue[700] : Colors.grey[800],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
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
                selectedColor: Colors.blue[50],
                backgroundColor: Colors.grey[100],
                checkmarkColor: Colors.blue[700],
                elevation: isSelected ? 2 : 0,
                pressElevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? Colors.blue[200]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                fontSize: 13,
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

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (hasActiveFilters) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[100]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 16,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getActiveFiltersText(filterState),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: hasActiveFilters
                      ? () => _showResetConfirmation(context, ref)
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: hasActiveFilters
                          ? Colors.blue[600]!
                          : Colors.grey[400]!,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor:
                        hasActiveFilters ? Colors.blue[600] : Colors.grey[400],
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor:
                        hasActiveFilters ? Colors.blue[600] : Colors.grey[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: hasActiveFilters ? 3 : 0,
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
