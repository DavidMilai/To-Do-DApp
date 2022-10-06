import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:tododapp/models/note_model.dart';
import 'package:tododapp/services/notes_service.dart';

class AllNotesScreen extends StatefulWidget {
  const AllNotesScreen({Key? key}) : super(key: key);

  @override
  State<AllNotesScreen> createState() => _AllNotesScreenState();
}

class _AllNotesScreenState extends State<AllNotesScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var notesService = context.watch<NotesService>();
    return Scaffold(
      appBar: AppBar(title: Text("All notes")),
      body: notesService.isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                print("hello");
              },
              child: ListView.builder(
                  itemCount: notesService.notes.length,
                  itemBuilder: (context, index) {
                    Note note = notesService.notes[index];
                    return ListTile(
                        title: Text(note.title),
                        subtitle: Text(note.description),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => notesService.deleteNote(note.id),
                        ));
                  }),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('New Note'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'Enter title',
                      ),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Enter description',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      notesService.addNote(
                        titleController.text,
                        descriptionController.text,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
