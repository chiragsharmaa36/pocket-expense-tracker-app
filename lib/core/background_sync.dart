import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';
// Import your repositories and models here
import '../features/expenses/data/expense.dart';
import '../features/expenses/data/expense_repository.dart';
import '../features/expenses/data/firebase_repository.dart';
import 'package:isar/isar.dart';

import '../firebase_options.dart';

// CRITICAL: This exact pragma tells the compiler NOT to strip this 
// function out during release builds, because no UI code calls it.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {

// CRITICAL NEW LINE: Boot up the Flutter engine in the background
    WidgetsFlutterBinding.ensureInitialized();

    print("🌙 BACKGROUND TASK WOKE UP: $task");

    try {
        // CRITICAL NEW LINE: Pass the options so it knows WHICH project to connect to
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform, 
      );
     final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([ExpenseSchema], directory: dir.path);

  final localRepository = ExpenseRepository(isar);
  final cloudRepository = FirebaseRepository();

      // Run the exact same sync logic we built for the Bloc!
      final pendingItems = await localRepository.getPendingSyncExpenses();
      
      if (pendingItems.isNotEmpty) {
        print('🌙 BACKGROUND: Found ${pendingItems.length} items. Syncing...');
        await cloudRepository.pushExpensesBatch(pendingItems);
        localRepository.markExpensesAsSynced(pendingItems);
        print('🌙 BACKGROUND: Sync complete!');
      }

      return Future.value(true); // Tell the OS we succeeded
    } catch (e) {
      print("🚨 BACKGROUND TASK FAILED: $e");
      return Future.value(false); // Tell the OS to try again later
    }
  });
}