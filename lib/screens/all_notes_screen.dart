import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:tododapp/models/note_model.dart';
import 'package:tododapp/services/notes_service.dart';

class AllNOtesScreen extends StatefulWidget {
  const AllNOtesScreen({Key? key}) : super(key: key);

  @override
  State<AllNOtesScreen> createState() => _AllNOtesScreenState();
}

class _AllNOtesScreenState extends State<AllNOtesScreen> {
  @override
  Widget build(BuildContext context) {
    var notesService = context.watch<NotesService>();
    return Scaffold(
        appBar: AppBar(title: Text("All notes")),
        body: ListView.builder(
            itemCount: notesService.allNotes.length,
            itemBuilder: (context, index) {
              Note note = notesService.allNotes[index];
              return ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.description),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      notesService.deleteNote(note.id);
                    },
                  ));
            }));
  }
}
