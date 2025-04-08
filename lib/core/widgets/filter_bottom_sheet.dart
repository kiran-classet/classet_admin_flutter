import 'package:classet_admin/core/utils/filter_data_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';

class FilterButtonWidget extends ConsumerWidget {
  final VoidCallback? onFilterApplied;
  final VoidCallback? onFilterReset;

  const FilterButtonWidget({
    super.key,
    this.onFilterApplied,
    this.onFilterReset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminUserState = ref.watch(adminUserProvider);
    final userDetails = adminUserState.userDetails;

    // Initialize default filter state if not already set
    if (userDetails != null && ref.read(filterStateProvider).branch == null) {
      Future.microtask(() {
        final branches =
            FilterDataParser.getBranchesFromUserDetails(userDetails);
        if (branches.isNotEmpty) {
          final firstBranch = branches.first['branchId'];
          final boards =
              FilterDataParser.getBoardsFromBranch(userDetails, firstBranch);
          final firstBoard = boards.isNotEmpty ? boards.first['boardId'] : null;
          final classes = firstBoard != null
              ? FilterDataParser.getClassesFromBoard(
                  userDetails, firstBranch, firstBoard)
              : [];
          final firstClass =
              classes.isNotEmpty ? classes.first['classId'] : null;
          final sections = firstClass != null
              ? FilterDataParser.getSectionsFromClass(
                  userDetails, firstBranch, firstBoard!, firstClass)
              : [];
          final firstSection =
              sections.isNotEmpty ? [sections.first['sectionId']] : [];

          ref.read(filterStateProvider.notifier).state = FilterState(
            branch: firstBranch,
            board: firstBoard,
            grade: firstClass,
            section: firstSection.cast<String>(),
          );
        }
      });
    }

    return FloatingActionButton(
      onPressed: () {
        if (userDetails != null) {
          _showFilterBottomSheet(context, ref, userDetails);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User details not available')),
          );
        }
      },
      tooltip: 'Filter',
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      child: const Icon(Icons.filter_list),
    );
  }

  void _showFilterBottomSheet(
      BuildContext context, WidgetRef ref, Map<String, dynamic> userDetails) {
    final branches = FilterDataParser.getBranchesFromUserDetails(userDetails);

    // Load main state into temporary state
    ref
        .read(tempFilterStateProvider.notifier)
        .loadFromMainState(ref.read(filterStateProvider));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        branches: branches,
        userDetails: userDetails,
        onFilterApplied: onFilterApplied,
        onFilterReset: onFilterReset,
      ),
    );
  }
}

class FilterBottomSheet extends ConsumerWidget {
  final List<dynamic> branches;
  final Map<String, dynamic> userDetails;
  final VoidCallback? onFilterApplied;
  final VoidCallback? onFilterReset;
  final bool showSections;

  const FilterBottomSheet({
    super.key,
    required this.branches,
    required this.userDetails,
    this.onFilterApplied,
    this.onFilterReset,
    this.showSections = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tempFilterState = ref.watch(tempFilterStateProvider);

    final availableBoards = tempFilterState.branch != null
        ? FilterDataParser.getBoardsFromBranch(
            userDetails, tempFilterState.branch!)
        : [];

    final availableClasses = tempFilterState.board != null
        ? FilterDataParser.getClassesFromBoard(
            userDetails, tempFilterState.branch!, tempFilterState.board!)
        : [];

    final availableSections = tempFilterState.grade != null
        ? FilterDataParser.getSectionsFromClass(
            userDetails,
            tempFilterState.branch!,
            tempFilterState.board!,
            tempFilterState.grade!)
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      valueKey: 'branchId',
                      displayKey: 'branchName',
                      selectedValue: tempFilterState.branch,
                      onSelected: (value) => ref
                          .read(tempFilterStateProvider.notifier)
                          .updateBranch(value),
                    ),
                    if (tempFilterState.branch != null) ...[
                      const SizedBox(height: 24),
                      _buildFilterSection(
                        context: context,
                        ref: ref,
                        title: 'Board',
                        items: availableBoards,
                        valueKey: 'boardId',
                        displayKey: 'boardName',
                        selectedValue: tempFilterState.board,
                        onSelected: (value) => ref
                            .read(tempFilterStateProvider.notifier)
                            .updateBoard(value),
                      ),
                    ],
                    if (tempFilterState.board != null) ...[
                      const SizedBox(height: 24),
                      _buildFilterSection(
                        context: context,
                        ref: ref,
                        title: 'Grade',
                        items: availableClasses,
                        valueKey: 'classId',
                        displayKey: 'className',
                        selectedValue: tempFilterState.grade,
                        onSelected: (value) => ref
                            .read(tempFilterStateProvider.notifier)
                            .updateGrade(value),
                      ),
                    ],
                    if (showSections && tempFilterState.grade != null) ...[
                      const SizedBox(height: 24),
                      _buildFilterSection(
                        context: context,
                        ref: ref,
                        title: 'Section',
                        items: availableSections,
                        valueKey: 'sectionId',
                        displayKey: 'sectionName',
                        selectedValues: tempFilterState.section,
                        onSelected: (values) => ref
                            .read(tempFilterStateProvider.notifier)
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
                color: Colors.black87),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.close, color: Colors.grey[600], size: 24),
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
              color: Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Text(
            'No options available',
            style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                fontSize: 14),
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
                      fontWeight: FontWeight.w500),
                ),
                selected: isSelected,
                onSelected: (_) {
                  if (isMultiSelect) {
                    final newSelection = List<String>.from(selectedValues);
                    isSelected
                        ? newSelection.remove(value)
                        : newSelection.add(value);
                    onSelected(newSelection);
                  } else {
                    onSelected(isSelected ? null : value);
                  }
                },
                selectedColor: Colors.blue[50],
                backgroundColor: Colors.grey[100],
                checkmarkColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                      color: isSelected ? Colors.blue[200]! : Colors.grey[300]!,
                      width: 1),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    final tempFilterState = ref.watch(tempFilterStateProvider);
    final hasActiveFilters = tempFilterState.branch != null ||
        tempFilterState.board != null ||
        tempFilterState.grade != null ||
        tempFilterState.section.isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: hasActiveFilters
                  ? () => ref
                      .read(tempFilterStateProvider.notifier)
                      .resetTempFilters()
                  : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                    color: hasActiveFilters
                        ? Colors.blue[600]!
                        : Colors.grey[400]!,
                    width: 1.5),
              ),
              child: const Text('Reset',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: hasActiveFilters
                  ? () {
                      ref
                          .read(tempFilterStateProvider.notifier)
                          .applyTempState(ref);
                      onFilterApplied?.call();
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor:
                    hasActiveFilters ? Colors.blue[600] : Colors.grey[400],
              ),
              child: const Text('Apply',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
