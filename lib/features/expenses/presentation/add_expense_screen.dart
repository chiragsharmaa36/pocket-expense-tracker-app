import 'package:flutter/material.dart';
import '../../sync_station/presentation/bloc/sync_bloc.dart';
import '../../sync_station/presentation/bloc/sync_event.dart';
import '../data/expense.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/expense_bloc.dart';
import 'bloc/expense_event.dart';
import 'bloc/expense_state.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _saveExpense() {
    final newExpense = Expense()
      ..cloudId = Uuid().v4()
      ..title = _titleController.text
      ..amount = double.tryParse(_amountController.text) ?? 0.0
      ..category = 'General'
      ..timestamp = DateTime.now()
      ..latitude = 0.0
      ..longitude = 0.0
      ..isSynced = false;

    context.read<ExpenseBloc>().add(AddExpense(newExpense));
  }

  @override
  Widget build(BuildContext context) {
    // viewInsets.bottom is crucial here—it pushes the sheet up when the keyboard opens
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseActionSuccess) {
          context.read<SyncBloc>().add(LocalExpenseAdded());
          context.pop();
        } else if (state is ExpenseError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: bottomPadding + 16.0 // dynamic padding
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content height
          children: [
            const Text('Log Expense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'What was it?'),
              autofocus: true, // Pops the keyboard open instantly
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: _saveExpense,
              child: const Text('Save Locally'),
            )
          ],
        ),
      ),
    );


  }
}
