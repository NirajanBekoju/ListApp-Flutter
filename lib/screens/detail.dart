import 'package:flutter/material.dart';
import 'package:todo/models/note.dart';
import 'package:todo/utils/database_helper.dart';

class Detail extends StatefulWidget { 
  // Variable "title" for Receiving the input parameter
  final String title;
  final Note note;
  // Assigning value to the "title" by the coonstructor
  Detail(this.note,this.title);

  @override
  State<StatefulWidget> createState(){
    // Passing valur "title" to  the DetailState
    return DetailState(this.note,this.title); 
  }
}

class DetailState extends State<Detail>{
  // Database helper Class
  DatabaseHelper helper = DatabaseHelper();
  // Receiving the value through the constructor
  String title;
  Note note;
  DetailState(this.note,this.title);

  // Prorities Variable declaration
  List <String>priorities = <String>["High","Low"];
  String currentValue = 'Low';

  // Text controller for the form
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context){
    titleController.text = note.title;
    descriptionController.text = note.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
        // For the navigation.push i.e to return back to the previous screen
        leading: 
        IconButton(
          icon: Icon(Icons.arrow_back), 
          onPressed: (){
            Navigator.pop(context);
          }
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: ListView(
            children: <Widget>[
              // Beginning of the drop Down Menu
              Text('Priority', style: TextStyle(fontSize: 20),),
              ListTile(
                title: DropdownButton(
                  value: currentValue,

                  onChanged: (String newValue) {
                    setState(() {
                      currentValue = newValue;
                      updatePriorityAsInt(newValue);
                    });
                  },

                  items: priorities.map((String dropDownItem){
                    return DropdownMenuItem<String>(
                      child: Text(dropDownItem), 
                      value: dropDownItem,
                    );
                  }).toList(),
                )
              ),

              SizedBox(height: 20),
              // Text Field for the title
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
                onChanged: (value){
                  debugPrint("Title field is changed");
                  updateTitle();
                },
              ),

              SizedBox(height: 20),
              // Text Field for the description
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
                onChanged: (value){
                  debugPrint("Description field is changed");
                  updateDescription();
                },
              ),

              SizedBox(height: 20),
              // Raised Button Row => Save and Delete Button
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text('Save', style: TextStyle(color: Colors.white),),
                      color: Colors.green,
                      onPressed:(){
                        debugPrint("Save Button Pressed");
                        save();
                      }
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: RaisedButton(
                      child: Text('Delete', style: TextStyle(color: Colors.white),),
                      color: Colors.redAccent,
                      onPressed:(){
                        debugPrint("Delete Button Pressed");
                        delete();
                      }
                    ),
                  ),
                ] 
              ),  
            ]
          )
        )
      ),
    );
  }

  // Move to the last Screen
  void moveToLastScreen(){
    Navigator.pop(context, true);
    debugPrint('Moving to the last Screen');
  }
  // Convert the string priority in the frm of integer berfore saving to the database
  void updatePriorityAsInt(String value){
    switch(value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
      default:
        note.priority = 2;
    }
  }

  // update the title
  void updateTitle(){
    note.title = titleController.text;
  }

  // update the description
  void updateDescription(){
    note.description = descriptionController.text;
  }

  // Save the note data to the database
  void save() async{
    // Setting the "date" Property to the note
    // Move to the home screen
    moveToLastScreen();
    note.date = DateTime.now().toString();

    int result;
    if(note.id !=null){
      // Update The Note Data
      result = await helper.updateNote(note);
    }
    else{
      // Perform the Insert Operation
      result = await helper.insertNote(note);
    }
    if(result != 0){
      // Show success message
      showAlertDialog('Status', 'Note Saved Successfully');
    }
    else{
      showAlertDialog('Status','Problem Saving the note');
    }
  }

  // Delete the note
  void delete() async{
    moveToLastScreen();
    // Case: if present id or not
    if(note.id == null){
      showAlertDialog('Status', 'No note was deleted');
      return;
    }
    int result = await helper.deleteNote(note.id);
    if(result!=0){
      showAlertDialog('Status', 'Note Deleted Successfully');
    }
    else{
      showAlertDialog('Status', 'Problem deleting note');
    }
  }

  void showAlertDialog(String title, String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message)
    );

    showDialog(
      context: context,
      builder: (_) => alertDialog,
    );
  }

}