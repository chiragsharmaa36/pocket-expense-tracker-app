import 'package:isar/isar.dart';

import 'expense.dart';

class ExpenseRepository {
    final Isar isar;
    ExpenseRepository(this.isar);

    Future<void> addExpense(Expense expense) async {
        await isar.writeTxn(() async {
            await isar.expenses.put(expense);
        });
    }

    Future<List<Expense>> getAllExpenses() async {
        return await isar.expenses.where().sortByTimestampDesc().findAll();
    }

    Future<List<Expense>> getPendingSyncExpenses() async {
        return await isar.expenses.filter().isSyncedEqualTo(false).findAll();
    }

    void markExpensesAsSynced(List<Expense> expenses) {
        if (expenses.isEmpty) return;

        for (var expense in expenses) {
            expense.isSynced = true;
        }
        // write them all to Isar in ONE single synchronous transaction
        isar.writeTxnSync(() {
            isar.expenses.putAllSync(expenses);
        });
    }
}