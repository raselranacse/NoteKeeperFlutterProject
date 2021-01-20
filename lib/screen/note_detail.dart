import 'package:flutter/material.dart';
import 'dart:async';
import 'package:note_keeper/models/note.dart';
import 'package:intl/intl.dart';
import 'package:note_keeper/utils/database_helper.dart';
class NoteDetail extends StatefulWidget {
  final String appBartitle;
  final Note note;
  NoteDetail(this.note, this.appBartitle);

  @override
  _NoteDetailState createState() => _NoteDetailState(this.note, this.appBartitle);
}

class _NoteDetailState extends State<NoteDetail> {


  static var _priorities=['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  TextEditingController _titleEditingController=TextEditingController();
  TextEditingController _descriptionEditingController=TextEditingController();
  String appBartitle;
  Note note;
  _NoteDetailState(this.note, this.appBartitle);
  @override
  Widget build(BuildContext context) {
    _titleEditingController.text=note.title;
    _descriptionEditingController.text=note.description;
    return WillPopScope(
      onWillPop: (){
        moveToLast();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBartitle),
          leading: IconButton(icon: Icon(Icons.arrow_back),
          onPressed: (){
            moveToLast();
        },),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem){
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                          child: Text(dropDownStringItem));
                    }).toList(),
                    value: getPriorityAsString(note.priority),
                    onChanged: (valueSelectedByUser){
                    setState(() {
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: TextField(
                  controller: _titleEditingController,
                  onChanged: (value){
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        //borderRadius: BorderRadius.all(Radius.circular(8.0))
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        //borderRadius: BorderRadius.all(Radius.circular(8.0))
                      ),
                      labelText: 'Title',
                      labelStyle: TextStyle(fontStyle: FontStyle.normal,fontSize: 15,fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: Colors.white
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: TextField(
                  controller: _descriptionEditingController,
                  onChanged: (value){
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        //borderRadius: BorderRadius.all(Radius.circular(8.0))
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        //borderRadius: BorderRadius.all(Radius.circular(8.0))
                      ),
                      labelText: 'Description',
                      labelStyle: TextStyle(fontStyle: FontStyle.normal,fontSize: 15,fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: Colors.white
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height*.06,
                      width: MediaQuery.of(context).size.width*.40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.green[300]
                      ),
                      child: Center(
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                _save();
                              });
                            },
                            child: Text('Save',style:
                            TextStyle(color: Colors.white,fontSize: 15,
                                fontWeight: FontWeight.bold)),
                          ),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height*.06,
                      width: MediaQuery.of(context).size.width*.40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.green[300]
                      ),
                      child: Center(
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                _delete();
                              });
                            },
                              child: Text('Delete',style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold)))),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  void moveToLast(){
Navigator.pop(context, true);
  }
void updatePriorityAsInt(String value){
    switch(value){
      case 'High':
        note.priority=1;
        break;
      case 'Low':
        note.priority=2;
        break;
    }
}
String getPriorityAsString(int value){
    String priority;
    switch(value){
      case 1:
        priority=_priorities[0];
        break;
      case 2:
        priority=_priorities[1];
        break;
    }
    return priority;
}

void updateTitle(){
    note.title=_titleEditingController.text;
}
void updateDescription(){
    note.description=_descriptionEditingController.text;
}

void _save() async{
    moveToLast();

    note.date=DateFormat.yMMMd().format(DateTime.now());
    int result;
    if(note.id != null){
     result= await helper.updateNote(note);
    }else{
      result= await helper.insertNote(note);
    }
    if(result!=0){
      _showAlterDialog('Status', 'Note Saved Successfully');
    }else{
      _showAlterDialog('Status', 'Problem Saving Note');
    }
}

void _delete() async{

    moveToLast();
    if(note.id==null){
      _showAlterDialog('Status', 'No note was deleted');
      return;
    }
    int result = await helper.deleteNote(note.id);
    if(result!=0){
      _showAlterDialog('Status', 'Note deleted Successfully');
    }else{
      _showAlterDialog('Status', 'Error occured while deleting note');
    }
}

void _showAlterDialog(String title, String message){
    AlertDialog alertDialog=AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_)=> alertDialog
    );
}
}

