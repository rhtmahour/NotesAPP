import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  ///singleton
  DBHelper._();

  static final DBHelper getInsatnce = DBHelper._();

  ///table note
  static final TABLE_NOTE = "note";
  static final COLUMN_NOTE_SNO = "s_no";
  static final COLUMN_NOTE_TITLE = "title";
  static final COLUMN_NOTE_DESC = "desc";

  Database? myDB;

  ///db open (if exists, then open it, else create it and open it)
  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;
    /*if (myDB != null) {
      return myDB!;
    } else {
      myDB = await openDB();
      return myDB!;
    }*/
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();

    String dbPath = join(appDir.path, "noteDB.db");
    return await openDatabase(
      dbPath,
      onCreate: (db, version) {
        ///create all your tables here
        db.execute(
          "create table $TABLE_NOTE($COLUMN_NOTE_SNO integer primary key autoincrement, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text)",
          //
          //
          //
          //
        );
      },
      version: 1,
    );
  }

  ///all queries will be executed after db is opened
  ///insert note
  Future<bool> addNote({required String mtitle, required String mdesc}) async {
    var db = await getDB();
    int rowsEffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: mtitle,
      COLUMN_NOTE_DESC: mdesc,
    });
    return rowsEffected > 0;
  }

  ///Reading all notes
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();

    ///select * from note
    List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);
    return mData;
  }

  ///update note
  Future<bool> updateNote({
    required String mtitle,
    required String mdesc,
    required int sno,
  }) async {
    var db = await getDB();
    int rowsEffected = await db.update(
      TABLE_NOTE,
      {COLUMN_NOTE_TITLE: mtitle, COLUMN_NOTE_DESC: mdesc},
      where: "$COLUMN_NOTE_SNO = ?",
      whereArgs: [sno],
    );
    return rowsEffected > 0;
  }

  ///delete note
  Future<bool> deleteNote(int sno) async {
    var db = await getDB();
    int rowsEffected = await db.delete(
      TABLE_NOTE,
      where: "$COLUMN_NOTE_SNO = ?",
      whereArgs: [sno],
    );
    return rowsEffected > 0;
  }
}
