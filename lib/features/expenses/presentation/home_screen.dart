import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'add_expense_screen.dart';
import 'bloc/expense_bloc.dart';
import 'bloc/expense_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Vault')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (context) => AddExpenseScreen(),
        ),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        buildWhen: (previousState, currentState) {
          // Only rebuild the UI if the new state is NOT an action success.
          // This keeps the old list perfectly visible on the screen!
          return currentState is! ExpenseActionSuccess;
        },
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExpenseError) {
            return Center(child: Text(state.message));
          }

          if (state is ExpenseLoaded) {
            if (state.expenses.isEmpty) {
              return const Center(child: Text('No expenses yet.'));
            }
            return ListView.builder(
              itemCount: state.expenses.length,
              itemBuilder: (context, index) {
                final expense = state.expenses[index];
                return ListTile(
                  title: Text(expense.title),
                  subtitle: Text(
                    '\u{20B9} ${expense.amount.toStringAsFixed(2)}',
                  ),
                  trailing: Icon(
                    expense.isSynced ? Icons.cloud_done : Icons.cloud_off,
                    color: expense.isSynced ? Colors.green : Colors.grey,
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
