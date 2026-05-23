import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/ponto_registro.dart';

class PontoDatabase {
  PontoDatabase._();

  static final PontoDatabase instance = PontoDatabase._();

  static const _databaseName = 'ponto_azul.db';
  static const _databaseVersion = 2;
  static const _tableName = 'pontos';

  Database? _database;

  Future<Database> get database async {
    final currentDatabase = _database;
    if (currentDatabase != null) {
      return currentDatabase;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    final database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    _database = database;
    return database;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        tipo TEXT NOT NULL,
        data_hora TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        endereco TEXT NOT NULL,
        sincronizado INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE $_tableName ADD COLUMN endereco TEXT NOT NULL DEFAULT 'Endereço não localizado'",
      );
    }
  }

  Future<void> inserir(PontoRegistro registro) async {
    final db = await database;
    await db.insert(
      _tableName,
      registro.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PontoRegistro>> listarUltimos({int limit = 20}) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'data_hora DESC',
      limit: limit,
    );

    return maps.map(PontoRegistro.fromMap).toList();
  }

  Future<int> sincronizarPendentes() async {
    final db = await database;
    return db.update(
      _tableName,
      {'sincronizado': 1},
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
  }
}
