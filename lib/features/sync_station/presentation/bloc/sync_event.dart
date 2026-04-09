sealed class SyncEvent {}

class LocalExpenseAdded extends SyncEvent {}

class NetworkChanged extends SyncEvent{
    final bool isConnected;
    NetworkChanged(this.isConnected);
}

class TriggerSync extends SyncEvent{}