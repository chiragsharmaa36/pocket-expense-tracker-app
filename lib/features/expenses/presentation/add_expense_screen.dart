import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/location_service.dart';
import '../../sync_station/presentation/bloc/sync_bloc.dart';
import '../../sync_station/presentation/bloc/sync_event.dart';
import '../data/expense.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/expense_bloc.dart';
import 'bloc/expense_event.dart';
import 'bloc/expense_state.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/custom_action_button.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _preFetchLocation();
  }

  Future<void> _preFetchLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  void _saveExpense() {
    final newExpense = Expense()
      ..cloudId = Uuid().v4()
      ..title = _titleController.text
      ..amount = double.tryParse(_amountController.text) ?? 0.0
      ..category = 'General'
      ..timestamp = DateTime.now()
      ..latitude = _currentPosition?.latitude ?? 0.0
      ..longitude = _currentPosition?.longitude ?? 0.0
      ..isSynced = false;

    context.read<ExpenseBloc>().add(AddExpense(newExpense));
  }

  @override
  Widget build(BuildContext context) {
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
            left: 20.0,
            right: 20.0,
            top: 16.0,
            bottom: bottomPadding + 32.0 // dynamic padding
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content height
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Text('Log Expense', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _titleController,
              placeholder: 'What was it?',
              autofocus: true, 
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              placeholder: 'Amount',
            ),
            const SizedBox(height: 32),
            CustomActionButton(
              onPressed: _saveExpense,
              text: 'Save Locally',
            )
          ],
        ),
      ),
    );
  }
}
