import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:speak/models/item.dart';

class DbHelper {
  static final DbHelper _dbHelper = DbHelper._internal();

  String tblItems = "items";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colType = "type";
  // String colPriority = "priority";
  String colDate = "date";

  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  static Database _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await initializeDb();
    }
    return _db;
  }

  Future<Database> initializeDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "speak.db";
    var dbSpeak = await openDatabase(path, version: 1, onCreate: _createDb);
    return dbSpeak;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $tblItems($colId INTEGER PRIMARY KEY, $colTitle TEXT, $colDescription TEXT, $colType INTEGER, $colDate TEXT)");
  }

  Future<int> insertItem(Item item) async {
    Database db = await this.db;

    var result = await db.insert(tblItems, item.toMap());
    return result;
  }

  Future<List> getItems() async {
    Database db = await this.db;

    var result = await db.rawQuery("SELECT * from $tblItems");
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.db;

    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT count(*) from $tblItems"));
    return result;
  }

  Future<int> updateItem(Item item) async {
    Database db = await this.db;

    var result = await db.update(tblItems, item.toMap(),
        where: "$colId = ?", whereArgs: [item.id]);

    return result;
  }

  Future<int> deleteItem(int id) async {
    int result;

    Database db = await this.db;

    result = await db.rawDelete('DELETE FROM $tblItems where $colId = $id');
    return result;
  }
}
