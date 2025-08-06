import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class Db {
  static final Db _singleton = Db._();

  factory Db() => _singleton;

  Db._();

  Database? _database;
  String? _path;
  String? _shadowPath;
  bool _initialized = false;

  Future<void> initialize() async {
    if (!_initialized) {
      final dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      final dbPath = join(dir.path, 'my_database.db');
      _path = dbPath;
      _shadowPath = join(dir.path, 'shadow.db');
      _database = await databaseFactoryIo.openDatabase(dbPath);
      _initialized = true;
    }
  }

  Database get db {
    if (!_initialized) {
      throw StateError(
          'Database not initialized. Call AppDatabase().initialize() first.');
    }
    return _database!;
  }

  String get path {
    if (!_initialized) {
      throw StateError(
          'Database not initialized. Call AppDatabase().initialize() first.');
    }
    return _path!;
  }

  String get shadowPath {
    if (!_initialized) {
      throw StateError(
          'Database not initialized. Call AppDatabase().initialize() first.');
    }
    return _shadowPath!;
  }

  bool get isInitialized => _initialized;
}
