import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'core/background_sync.dart';
import 'core/routing/app_router.dart';
import 'package:isar/isar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'features/expenses/data/expense.dart';
import 'features/expenses/data/expense_repository.dart';
import 'features/expenses/data/firebase_repository.dart';
import 'features/expenses/presentation/bloc/expense_bloc.dart';
import 'features/expenses/presentation/bloc/expense_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/sync_station/presentation/bloc/sync_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Workmanager().initialize(callbackDispatcher);

  Workmanager().registerPeriodicTask(
    "1", // A unique ID for this task
    "com.yourdomain.pocketexpense.syncTask", // The ID we put in iOS Info.plist
    frequency: const Duration(hours: 1), // Minimum is 15 mins on Android
    constraints: Constraints(
      networkType: NetworkType.connected, // Only run if internet is available!
      requiresBatteryNotLow: true, // Don't kill the user's phone
    ),
  );

  // // For Testing purpose
  // Workmanager().registerOneOffTask(
  //   "instant_recovery_sync",
  //   "com.yourdomain.pocketexpense.syncTask",
  //   // TEMPORARILY REMOVED CONSTRAINTS FOR EMULATOR TESTING
  //   initialDelay: const Duration(seconds: 5),
  // );

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([ExpenseSchema], directory: dir.path);

  final localRepository = ExpenseRepository(isar);
  final cloudRepository = FirebaseRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ExpenseBloc>(
          create: (context) => ExpenseBloc(localRepository)..add(LoadLogs()),
        ),
        BlocProvider<SyncBloc>(
          lazy:
              false, // Ensure SyncBloc starts immediately to monitor connectivity
          create: (context) => SyncBloc(
            localRepo: localRepository,
            cloudRepo: cloudRepository,
            expenseBloc: context.read<ExpenseBloc>(),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.dark(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
