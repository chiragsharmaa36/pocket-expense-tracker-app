import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pocket_expense_tracker_app/features/sync_station/presentation/bloc/sync_event.dart';
import 'package:pocket_expense_tracker_app/features/sync_station/presentation/bloc/sync_state.dart';
import '../../../expenses/data/expense_repository.dart';
import '../../../expenses/data/firebase_repository.dart';
import '../../../expenses/presentation/bloc/expense_bloc.dart';
import '../../../expenses/presentation/bloc/expense_event.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final ExpenseRepository localRepo;
  final FirebaseRepository cloudRepo;
  final ExpenseBloc expenseBloc;

  late StreamSubscription<List<ConnectivityResult>> _networkSubscription;
  Timer? _debounceTimer;

  SyncBloc({
    required this.localRepo,
    required this.cloudRepo,
    required this.expenseBloc,
  }) : super(SyncIdle()) {
    _checkInitialConnection();
    _networkSubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      print('📡 SYNC: Hardware network change detected: $results');
      final isConnected = !results.contains(ConnectivityResult.none);
      add(
        NetworkChanged(isConnected),
      ); // add an event to trigger the sync logic
    });

    on<LocalExpenseAdded>((event, emit) async {
      _debounceTimer?.cancel(); // Cancel any existing timer
      _debounceTimer = Timer(const Duration(seconds: 5), () async {
        print(
          '⏱️ SYNC: Debounce finished. No new typing detected. Firing sync!',
        );
        if (await hasActualInternet()) {
          print('🚀 SYNC: Internet available after debounce. Triggering sync!');
          add(TriggerSync());
        }
      });
    });

    on<NetworkChanged>((event, emit) async {
      if (event.isConnected) {
        final realInternet = await hasActualInternet();
        if (realInternet) {
          print('🚀 SYNC: Firing TriggerSync event!');
          add(TriggerSync());
        } else {
          emit(SyncFailure('No actual internet connection'));
        }
      }
    });

    on<TriggerSync>((event, emit) async {
      emit(SyncInProgress());
      try {
        final pendingItems = await localRepo.getPendingSyncExpenses();
        if (pendingItems.isEmpty) {
          emit(SyncIdle());
          return;
        }
        print('📦 SYNC: Found ${pendingItems.length} items. Packing batch...');

        await cloudRepo.pushExpensesBatch(pendingItems);
        print('☁️ SYNC: Batch upload to Firebase complete!');

        localRepo.markExpensesAsSynced(pendingItems);
        print('💾 SYNC: Isar local database batch updated!');

        print('🎉 SYNC: All local items marked as synced!');
        expenseBloc.add(LoadLogs());
        emit(SyncSuccess());
      } catch (e) {
        print('🚨 SYNC ENGINE ERROR: $e');
        emit(SyncFailure('Failed to sync expenses'));
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    if (!results.contains(ConnectivityResult.none)) {
      final realInternet = await hasActualInternet();
      if (realInternet) add(TriggerSync());
    }
  }

  @override
  Future<void> close() {
    _networkSubscription.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}

Future<bool> hasActualInternet() async {
  print('🔍 SYNC: Checking for real internet...');
  try {
    // Pinging Google's DNS. If this fails, the internet is down.
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (e) {
    print('❌ SYNC: Internet check failed or timed out: $e');
    return false; // Caught the captive portal or dead router!
  }
}
