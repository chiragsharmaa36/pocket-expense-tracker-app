import 'package:bloc/bloc.dart';

import '../../data/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState>{
    final ExpenseRepository expenseRepository;
    ExpenseBloc(this.expenseRepository) : super(ExpenseLoading()){
        on<LoadLogs>((event, emit) async {
            emit(ExpenseLoading());
            try{
                final expenses = await expenseRepository.getAllExpenses();
                emit(ExpenseLoaded(expenses));
            } catch(e){
                emit(ExpenseError('Failed to load expenses: $e'));
            }
        });

        on<AddExpense>((event, emit) async{
            try{
                await expenseRepository.addExpense(event.expense);
                emit(ExpenseActionSuccess());
                final expenses = await expenseRepository.getAllExpenses();
                emit(ExpenseLoaded(expenses));
            } catch(e){
                emit(ExpenseError('Failed to add expense: $e'));
            }
        });
    }
}