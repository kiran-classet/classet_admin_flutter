import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../providers/filter_provider.dart';
import '../constants/constants.dart';

class FilterButtonWidget extends ConsumerWidget {
  final VoidCallback? onFilterApplied;

  const FilterButtonWidget({
    Key? key,
    this.onFilterApplied,
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
      builder: (context) => Consumer(
        builder: (context, dialogRef, child) {
          final filters = dialogRef.watch(filterProvider);

          List<dynamic> availableBoards = filters['branch'] != null
              ? boards
                  .where((board) => (board['assignedBranches'] as List)
                      .contains(filters['branch']))
                  .toList()
              : [];

          List<dynamic> availableClasses = filters['board'] != null
              ? (boards.firstWhere(
                      (board) => board['boardId'] == filters['board'],
                      orElse: () => {'classes': []})['classes'] as List)
                  .toList()
              : [];

          List<dynamic> availableSections = filters['grade'] != null &&
                  filters['branch'] != null
              ? (availableClasses.firstWhere(
                      (cls) => cls['classId'] == filters['grade'],
                      orElse: () => {'sections': []})['sections'] as List)
                  .where((section) => section['branchId'] == filters['branch'])
                  .toList()
              : [];

          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Branch filter (single select)
                        _buildFilterSection(
                          title: 'Branch',
                          items:
                              branches.map((b) => b['key'] as String).toList(),
                          displayItems:
                              branches.map((b) => b['name'] as String).toList(),
                          selectedItem: filters['branch'] as String?,
                          selectedItems: const [],
                          onSelected: (value) {
                            final newFilters = {
                              'branch':
                                  value == filters['branch'] ? null : value,
                              'board': null,
                              'grade': null,
                              'section': <String>[],
                            };
                            dialogRef
                                .read(filterProvider.notifier)
                                .updateFilters(newFilters);
                          },
                          isMultiSelect: false,
                        ),
                        if (filters['branch'] != null) ...[
                          const SizedBox(height: 24),
                          // Board filter (single select)
                          _buildFilterSection(
                            title: 'Board',
                            items: availableBoards
                                .map((b) => b['boardId'] as String)
                                .toList(),
                            displayItems: availableBoards
                                .map((b) => b['boardName'] as String)
                                .toList(),
                            selectedItem: filters['board'] as String?,
                            selectedItems: const [],
                            onSelected: (value) {
                              final newFilters = {
                                ...filters,
                                'board':
                                    value == filters['board'] ? null : value,
                                'grade': null,
                                'section': <String>[],
                              };
                              dialogRef
                                  .read(filterProvider.notifier)
                                  .updateFilters(newFilters);
                            },
                            isMultiSelect: false,
                          ),
                        ],
                        if (filters['board'] != null) ...[
                          const SizedBox(height: 24),
                          // Grade filter (single select)
                          _buildFilterSection(
                            title: 'Grade',
                            items: availableClasses
                                .map((c) => c['classId'] as String)
                                .toList(),
                            displayItems: availableClasses
                                .map((c) => c['className'] as String)
                                .toList(),
                            selectedItem: filters['grade'] as String?,
                            selectedItems: const [],
                            onSelected: (value) {
                              final newFilters = {
                                ...filters,
                                'grade':
                                    value == filters['grade'] ? null : value,
                                'section': <String>[],
                              };
                              dialogRef
                                  .read(filterProvider.notifier)
                                  .updateFilters(newFilters);
                            },
                            isMultiSelect: false,
                          ),
                        ],
                        if (filters['grade'] != null) ...[
                          const SizedBox(height: 24),
                          // Section filter (multi select)
                          _buildFilterSection(
                            title: 'Section',
                            items: availableSections
                                .map((s) => s['sectionId'] as String)
                                .toList(),
                            displayItems: availableSections
                                .map((s) => s['sectionName'] as String)
                                .toList(),
                            selectedItem: null,
                            selectedItems: filters['section'] as List<String>,
                            onSelected: (value) {
                              final currentSections =
                                  List<String>.from(filters['section']);
                              if (currentSections.contains(value)) {
                                currentSections.remove(value);
                              } else {
                                currentSections.add(value);
                              }
                              final newFilters = {
                                ...filters,
                                'section': currentSections,
                              };
                              dialogRef
                                  .read(filterProvider.notifier)
                                  .updateFilters(newFilters);
                            },
                            isMultiSelect: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          dialogRef
                              .read(filterProvider.notifier)
                              .resetFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (onFilterApplied != null) {
                            onFilterApplied!();
                          }
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> items,
    required List<String> displayItems,
    String? selectedItem,
    required List<String> selectedItems,
    required Function(String) onSelected,
    required bool isMultiSelect,
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
          const Text('No options available')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final displayName = displayItems[index];
              final isSelected = isMultiSelect
                  ? selectedItems.contains(item)
                  : selectedItem == item;

              return FilterChip(
                label: Text(displayName),
                selected: isSelected,
                onSelected: (_) => onSelected(item),
                selectedColor: Colors.blue.withOpacity(0.2),
                checkmarkColor: Colors.blue,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
