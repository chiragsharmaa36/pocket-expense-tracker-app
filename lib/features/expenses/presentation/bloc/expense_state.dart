import 'package:bloc/bloc.dart';

import '../../data/expense.dart';

sealed class ExpenseState{}

class ExpenseLoading extends ExpenseState{}

class ExpenseLoaded extends ExpenseState{
    final List<Expense> expenses;
     ExpenseLoaded(this.expenses);
}

class ExpenseActionSuccess extends ExpenseState {}

class ExpenseError extends ExpenseState{
    final String message;
    ExpenseError(this.message);
}