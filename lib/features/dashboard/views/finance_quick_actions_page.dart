import 'package:flutter/material.dart';
import 'package:classet_admin/core/widgets/filter_button_widget.dart';
import 'package:classet_admin/core/providers/filter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinanceQuickActionsPage extends ConsumerStatefulWidget {
  const FinanceQuickActionsPage({super.key});

  @override
  ConsumerState<FinanceQuickActionsPage> createState() =>
      _FinanceQuickActionsPageState();
}

class _FinanceQuickActionsPageState
    extends ConsumerState<FinanceQuickActionsPage> {
  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(filterStateProvider); // Listen to changes
    print('Loaded filter state: $filterState');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Current Filters: $filterState'), // Debugging filter state
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildActionItem(
                      context, 'Collect Fee', Icons.attach_money, Colors.green),
                  _buildActionItem(context, 'Concession Approvals',
                      Icons.check_circle, Colors.blue),
                  _buildActionItem(context, 'Refund Approvals', Icons.money_off,
                      Colors.orange),
                  _buildActionItem(
                      context, 'Unassign Approvals', Icons.cancel, Colors.red),
                  _buildActionItem(context, 'Raise Concession',
                      Icons.arrow_upward, Colors.purple),
                  _buildActionItem(context, 'Raise Refund',
                      Icons.arrow_downward, Colors.teal),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FilterButtonWidget(
        showSections: false,
        isSingleSectionsSelection: false,
        onFilterApplied: () {
          print('Filters applied');
        },
      ),
    );
  }

  Widget _buildActionItem(
      BuildContext context, String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label: Coming Soon'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
