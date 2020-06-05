import 'package:sqflite/sqflite.dart'; //for SQFLite DB
import 'dart:async'; //for asynchronous programming
import 'dart:io'; //for dealing with files and folders
import 'package:path_provider/path_provider.dart';
import 'package:notekeeperapp/models/note.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; //singleton object of DatabaseHelper. Singleton means it runs once during application runtime
  static Database _database; //singleton Database

  String noteTable= 'note_table',
         colId= 'id',
         colTitle= 'title',
         colDescription= 'description',
         colPriority= 'priority',
         colDate= 'date';

  DatabaseHelper._createInstance(); //Named Constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    //factory allows you to return values in your constructor

    if(_databaseHelper==null) {
      _databaseHelper = DatabaseHelper._createInstance(); //this is executed only once. singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if(_database==null) {
      _database= await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    //Get directory path for both Android and iOS to store DB
    Directory directory= await getApplicationDocumentsDirectory();
    String path= directory.path + "notes.db";

    //Open/Create DB at given path
    var notesDatabase= await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  //CRUD Operations
  //Fetch Operation: get all Note objects from DB
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db= await this.database;

    //var result1= await db.rawQuery("SELECT * FROM $noteTable ORDER BY $colPriority ASC");
    var result= await db.query(noteTable, orderBy: "$colPriority ASC"); //second approach but same result
    return result;
  }

  //Insert Operation: insert a Note object to the DB
  Future<int> insertNote(Note note) async {
    Database db= await this.database;
    var result= await db.insert(noteTable, note.toMap());
    return result;
  }

  //Update Operation: Update a note object and save it to DB
  Future<int> updateNote(Note note) async {
    Database db= await this.database;
    var result= await db.update(noteTable, note.toMap(), where: "$colId= ?", whereArgs: [note.id]);
    return result;
  }

  //Delete Operation: delete a note object from DB
  Future<int> deleteNote(int id) async {
    Database db= await this.database;
    var result= await db.rawDelete("DELETE FROM $noteTable WHERE $colId= $id");
    return result;
  }

  //Get number of note objects in DB
  Future<int> getCount() async {
    Database db= await this.database;
    List<Map<String, dynamic>> x= await db.rawQuery("SELECT COUNT (*) FROM $noteTable");
    //the variable x is a list of map objects since the query will return a list of map objects
    int result= Sqflite.firstIntValue(x);
    return result;
  }

  //Get the 'Map list' [List<Map>] and convert it to 'Note List' [List<Note>]
  Future<List<Note>> getNoteList() async {
    var noteMapList= await getNoteMapList(); //get 'Map List' from DB
    int count= noteMapList.length; //count the number of map entries inDB table

    List<Note> noteList= List<Note>();
    //For loop to create a 'Note List' from a 'Map List'
    for(int i= 0; i< count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }
}