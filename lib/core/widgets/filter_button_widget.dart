import 'package:classet_admin/core/utils/filter_data_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';

class FilterButtonWidget extends ConsumerWidget {
  final VoidCallback? onFilterApplied;
  final VoidCallback? onFilterReset;
  final bool showSections; // Add parameter to control section visibility
  final bool isSingleSectionsSelection; // Add parameter
  final bool openBottomSheet;

  const FilterButtonWidget({
    super.key,
    this.onFilterApplied,
    this.onFilterReset,
    this.showSections = false, // Default to false
    this.isSingleSectionsSelection = false, // Default to false
    this.openBottomSheet = false,
  });

  void init(BuildContext context, WidgetRef ref) {
    if (openBottomSheet) {
      final adminUserState = ref.watch(adminUserProvider);
      final userDetails = adminUserState.userDetails;

      // Delay state modification
      Future.microtask(() {
        ref.read(filterStateProvider.notifier).state = FilterState(
          branch: ref.read(filterStateProvider).branch,
          board: ref.read(filterStateProvider).board,
          grade: ref.read(filterStateProvider).grade,
          section: [],
        );
      });

      if (userDetails != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFilterBottomSheet(context, ref, userDetails);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User filters not available')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    init(context, ref); // Call the init method
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
        showSections: showSections, // Pass the parameter
        isSingleSectionsSelection: isSingleSectionsSelection, // Pass the flag
        onFilterApplied: onFilterApplied,
        onFilterReset: onFilterReset,
      ),
    );
  }
}

class FilterBottomSheet extends ConsumerWidget {
  final List<dynamic> branches;
  final Map<String, dynamic> userDetails; // Add userDetails parameter
  final VoidCallback? onFilterApplied;
  final VoidCallback? onFilterReset;
  final bool showSections; // Add showSections parameter,
  final bool
      isSingleSectionsSelection; // Add isSingleSectionsSelection parameter

  const FilterBottomSheet({
    super.key,
    required this.branches,
    required this.userDetails, // Initialize userDetails
    this.onFilterApplied,
    this.onFilterReset,
    this.showSections = false, // Default to false
    this.isSingleSectionsSelection = false, // Default to false
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tempFilterState =
        ref.watch(tempFilterStateProvider); // Use temporary state

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
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align content to the top
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
                            .updateSections(values,
                                isSingleSectionsSelection:
                                    isSingleSectionsSelection),
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
    final tempFilterState = ref.watch(tempFilterStateProvider);
    final hasActiveFilters = tempFilterState.branch != null ||
        tempFilterState.board != null ||
        tempFilterState.grade != null ||
        tempFilterState.section.isNotEmpty;

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
                      _getActiveFiltersText(tempFilterState),
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
                          ref
                              .read(tempFilterStateProvider.notifier)
                              .applyTempState(ref); // Apply temp state
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
