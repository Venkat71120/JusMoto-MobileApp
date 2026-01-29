import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class DbHelper {
  static Future<Database> database(String dbName) async {
    final dbpath = await sql.getDatabasesPath();

    return sql.openDatabase(path.join(dbpath, '$dbName.db'), version: 1,
        onCreate: (db, version) {
      if (dbName == "cart") {
        db.execute(
            'CREATE TABLE $dbName(id INTEGER PRIMARY KEY,serviceId TEXT, service TEXT, quantity TEXT)');
        return;
      }
      db.execute(
          'CREATE TABLE $dbName(id INTEGER PRIMARY KEY,serviceId TEXT, data LONGTEXT)');
    });
  }

  static Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await DbHelper.database(table);
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> fetchDb(String table) async {
    final db = await DbHelper.database(table);

    return db.query(table);
  }

  static Future<void> updatedb(String table, id, data) async {
    final db = await DbHelper.database(table);

    db.update(
      table,
      data,
      where: 'serviceId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteDbTable(String table) async {
    final db = await DbHelper.database(table);
    db.delete(table);
  }

  static Future<void> deleteDbSI(String table, dynamic id) async {
    final db = await DbHelper.database(table);

    db.delete(
      table,
      where: 'serviceId = ?',
      whereArgs: [id],
    );
  }
}
