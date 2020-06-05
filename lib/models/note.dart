import 'package:flutter/cupertino.dart';

class Note {
  int _id,
      _priority;
  String _title,
         _description,
         _date;

    //Note objects
  Note(this._title, this._date, this._priority, [this._description]); //square bracket means it is an optional field

  Note.withId(this._id, this._title, this._date, this._priority, [this._description]); //square bracket means it is an optional field

  //create getter and setter for all fields
    //getters
  int get id=> _id;
  String get title=> _title;
  String get description=> _description;
  int get priority=> _priority;
  String get date=> _date;

    //setters
  //id does not need a setter since it'll be generated automatically by the DB
  set title(String newTitle) {
    //validations can be added to the set function
    if (newTitle.length <= 255) {
      this._title = newTitle;
    } else {
      print(Text("Please limit the number of characters"));
    }
  }

  set description(String newDescription) {
    if (newDescription.length <= 255)  {
      this._description= newDescription;
    }
  }

  set priority(int newPriority) {
    if(newPriority>= 1 && newPriority<= 2) {
      this._priority= newPriority;
    }
  }

  set date(String newDate) {
    this._date= newDate;
  }

  //Convert Note object to map object since SQLite deals with only map objects
  //Instantiating map object
  Map<String, dynamic> toMap() {
    // 'dynamic' means the value can be different datatypes
    var map= Map<String, dynamic>();

    if(_id!=null) {
      //checking if ID is empty
      map['id'] = _id;
    }
    map['title']= _title;
    map['description']= _description;
    map['priority']= _priority;
    map['date']= _date;

    return map;
  }

  //Extracting Note object from Map object so it can be displayed
  Note.fromMapObject(Map<String, dynamic> map) {
    this._id= map['id'];
    this._title= map['title'];
    this._description= map['description'];
    this._priority= map['priority'];
    this._date= map['date'];
  }
}