import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:note_keeper/models/note.dart';

class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable='note_table';
  String callId='id';
  String callTitle='title';
  String callDescription=' description';
  String callPriority='priority';
  String callDate='date';

  DatabaseHelper._createInstance();
  factory DatabaseHelper(){
    if(_databaseHelper==null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async{
    if(_database==null){
      _database=await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async{
    Directory directory= await getApplicationDocumentsDirectory();
    String path= directory.path +'notes.db';
    var notesDatabase= await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;

  }

  void _createDb(Database db, int newVersion) async{
    await db.execute('CREATE TABLE $noteTable($callId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$callTitle TEXT, $callDescription TEXT, $callDate TEXT, $callPriority INTEGER');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async{
    Database db= await this.database;
    var result = await db.query(noteTable, orderBy: '$callPriority ASC');
    return result;
  }
  Future<int> insertNote( Note note) async{
    Database db= await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }
  Future<int> updateNote( Note note) async{
    Database db= await this.database;
    var result = await db.update(noteTable, note.toMap(), where: '$callId=?', whereArgs: [note.id]);
    return result;
  }
  Future<int> deleteNote( int id) async{
    Database db= await this.database;
    //var result = await db.delete(noteTable, where: '$callId=?', whereArgs: [note.id]);
    var result= await db.rawDelete('DELETE FROM $noteTable WHERE $callId = $id' );
    return result;
  }
  Future<int> getCount()async{
    Database db= await this.database;
    List<Map<String, dynamic>> x= await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result=Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async{
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList= List<Note>();
    for(int i=0; i<count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }

}