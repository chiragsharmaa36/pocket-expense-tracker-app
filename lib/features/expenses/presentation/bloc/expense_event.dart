import 'package:pocket_expense_tracker_app/features/expenses/data/expense.dart';
import 'package:bloc/bloc.dart';

sealed class ExpenseEvent {}

class LoadLogs extends ExpenseEvent {}

class AddExpense extends ExpenseEvent{
    final Expense expense;
    AddExpense(this.expense);
}