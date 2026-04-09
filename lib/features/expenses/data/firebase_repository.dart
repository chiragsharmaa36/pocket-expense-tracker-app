import 'package:cloud_firestore/cloud_firestore.dart';
import 'expense.dart';

class FirebaseRepository {
    final FirebaseFirestore _firestore;

    FirebaseRepository({FirebaseFirestore? firestore}) : _firestore = FirebaseFirestore.instance;

    Future<void> pushExpense(Expense expense) async {
        final data = _expenseToMap(expense);
    // Push to Firestore using the pre-generated cloudId
    // We use .set() with SetOptions(merge: true) instead of .add()
    // This creates the document if it doesn't exist, or updates it if it does.
    await _firestore
        .collection('expenses')
        .doc(expense.cloudId)
        .set(data, SetOptions(merge: true));
    }

    Future<void> pushExpensesBatch(List<Expense> expenses) async {
      if (expenses.isEmpty) return;
      final chunks = _chunkList(expenses, 499);
      for(final chunk in chunks){
        final batch = _firestore.batch();
        for(final expense in chunk){
          final docRef = _firestore.collection('expenses').doc(expense.cloudId);
          final data = _expenseToMap(expense);

          // Add it to the batch (this does NOT trigger a network request yet)
          batch.set(docRef, data, SetOptions(merge: true));
        }
        await batch.commit();
      }
    }

    Map<String, dynamic> _expenseToMap(Expense expense) {
      return {
        'cloudId': expense.cloudId,
        'title': expense.title,
        'amount': expense.amount,
        'category': expense.category,
        'timestamp': expense.timestamp.toIso8601String(), // Firestore likes ISO strings or Timestamp objects
        'latitude': expense.latitude,
        'longitude': expense.longitude,
      };
    }

    // Helper method to split large lists
    List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
      List<List<T>> chunks = [];
      for (var i = 0; i < list.length; i += chunkSize) {
        int end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
        chunks.add(list.sublist(i, end));
      }
      return chunks;
    }
}