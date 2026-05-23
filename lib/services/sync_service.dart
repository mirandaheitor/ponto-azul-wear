import 'package:connectivity_plus/connectivity_plus.dart';

import '../database/ponto_database.dart';

class SyncServiceException implements Exception {
  const SyncServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SyncService {
  SyncService({Connectivity? connectivity, PontoDatabase? database})
    : _connectivity = connectivity ?? Connectivity(),
      _database = database ?? PontoDatabase.instance;

  final Connectivity _connectivity;
  final PontoDatabase _database;

  Future<int> sincronizarPendentes() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    final hasConnection = connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) {
      throw const SyncServiceException('Sem internet para sincronizar.');
    }

    return _database.sincronizarPendentes();
  }
}
