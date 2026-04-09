import 'package:isar/isar.dart';
part 'expense.g.dart';

@collection
class Expense {
    Id id = Isar.autoIncrement;
    late String cloudId;
    late String title;
    late String category;
    late double amount;
    late DateTime timestamp;
    late double latitude;
    late double longitude;
    bool isSynced = false;
}