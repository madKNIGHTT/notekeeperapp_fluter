import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekeeperapp/models/note.dart';
import 'package:notekeeperapp/utils/database_helper.dart';
import 'package:intl/intl.dart';

class TitleFieldValidator {
  static String validate(String value) {
    if(value== null || value.isEmpty) {
      return 'Title cannot be empty';
    }
    
    if(value.length>=21) {
      return 'Limit characters to 20';
    }
    return null;
  }
}class DescriptionFieldValidator {
  static String validate(String value) {
    if(value.length>=256) {
      return 'Limit characters to 255';
    }
    return null;
  }
}

class NoteDetail extends StatefulWidget {

  final String appBarTitle;
  final Note note;
  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return _NoteDetailState(this.note, this.appBarTitle);
  }
}

class _NoteDetailState extends State<NoteDetail> {
  static var _priorities = ["High", "Low"];

  DatabaseHelper helper= DatabaseHelper();

  String appBarTitle;
  Note note;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  _NoteDetailState(this.note, this.appBarTitle);

  final _formKey= GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text= note.title;
    descriptionController.text= note.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Form(
      child: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: DropdownButton(
                items: _priorities.map((String dropDownStringItem) {
                  return DropdownMenuItem<String>(
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                  );
                }).toList(),
                style: textStyle,
                value: getPriorityAsString(note.priority),
                onChanged: (valueSelectedByUser) {
                  setState(() {
                    debugPrint("User selected $valueSelectedByUser");
                    updatePriorityAsInt(valueSelectedByUser);
                  });
                },
              ),
            ),

            //Second Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextFormField(
                controller: titleController,
                style: textStyle,
                key: Key('title'),
                validator: TitleFieldValidator.validate,
                onChanged: (value) {
                  debugPrint("Something changed in title TextField");
                  updateTitle();
                },
                decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            //Third Element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextFormField(
                controller: descriptionController,
                style: textStyle,
                key: Key('description'),
                validator: DescriptionFieldValidator.validate,
                onChanged: (value) {
                  debugPrint("Something changed in description TextField");
                  updateDescription();
                },
                decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                            "Save",
                          textScaleFactor: 1.5,
                        ),

                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              debugPrint("Save button clicked");
                              _save();
                            });
                          }
                        }
                    ),
                  ),

                  Container(
                    width: 5.0,
                  ),

                  Expanded(
                    child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          "Delete",
                          textScaleFactor: 1.5,
                        ),

                        onPressed: () {
                          setState(() {
                            debugPrint("Delete button clicked");
                            _delete();
                          });
                        }
                    ),
                  ),

                ],
              ),
            )

          ],
        ),
      ),
    ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  //Convert the string priority to integer before saving it to the DB
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority= 1;
        break;
      case 'Low':
        note.priority= 2;
        break;
    }
  }

  //Convert int priority to string before displaying it to user dropdown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority= _priorities[0]; // 'High'
        break;
      case 2:
        priority= _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }

  //Update the title of Note object
  void updateTitle() {
    note.title= titleController.text;
  }

  //Update description of Note object
  void updateDescription() {
    note.description= descriptionController.text;
  }

  //Save data to database
  void _save() async {

    moveToLastScreen();

    note.date= DateFormat.yMMMd().format(DateTime.now()); //update date to current date & time
    int result;
    if(note.id!= null) { //Case 1: Update Operation
      result= await helper.updateNote(note);
    } else { //case 2: Insert operation
      result= await helper.insertNote(note);
    }

    if(result!=0) { //Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else { //Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {

    moveToLastScreen();

    //Case1: User is trying to delete new note i.e. he has come to
    //the detail page by pressing the FAB of the NoteList page
    if(note.id== null) {
      _showAlertDialog('Status', 'Since new note is not saved, no note was deleted');
      return;
    }

    //Case 2: User is trying to delete the old note that already has a valid ID
    int result= await helper.deleteNote(note.id);
    if(result!= 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog= AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }
}
