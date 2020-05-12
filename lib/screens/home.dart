import 'package:flutter/material.dart';
import 'package:todo/screens/detail.dart';
import 'package:todo/models/note.dart';
import 'package:todo/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState(){
    return HomeState(); 
  }
}

class HomeState extends State<Home> {
  
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList; 
  int _count = 0;
  
  @override
  Widget build(BuildContext context) {
    if(noteList == null){
      noteList = List<Note>();
      updateListView();
      debugPrint('Searching the notes object');
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      // Body of the todolist application
      body: 
      Container(
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: listitem(context),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          navigateToDetail(Note('','',2),'Add Note');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Function to return a todo list item
  Widget listitem(context){
    return 
    ListView.builder(
      itemCount: _count,
      itemBuilder: (context, position){
        return 
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),
            title: Text(this.noteList[position].title),
            subtitle: Text(this.noteList[position].date),
            trailing: 
            GestureDetector(
              child:Icon(Icons.delete, color: Colors.grey),
              onTap: (){
                _delete(context,noteList[position]);
              },
            ), 
            
            onTap: (){
              navigateToDetail(this.noteList[position],'Edit Note');
            },
          ),
        );
      }
    );
  }

  // Navigation to the detail page
  void navigateToDetail(Note note,String title) async{
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context){
      return Detail(note,title);
    }));

    if(result == true){
      updateListView();
    }
  }

  // Returns the priority color
  Color getPriorityColor(int priority){
    switch(priority){
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }

  //Return the priority icon
  Icon getPriorityIcon(int priority){
    switch(priority){
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    } 
  }

  void _delete(BuildContext context,Note note) async{
    int result = await databaseHelper.deleteNote(note.id);
    if(result!=0){
      _showSnackBar(context, "Note Deleted Successfully");
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message){
    final snackbar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackbar);
  }

  void updateListView() {

		final Future<Database> dbFuture = databaseHelper.initializeDatabase();
		dbFuture.then((database) {

			Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
			noteListFuture.then((noteList) {
				setState(() {
				  this.noteList = noteList;
				  this._count = noteList.length;
				});
			});
		});
  }
}