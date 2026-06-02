import 'package:flutter/material.dart';
import 'package:flutter_sqlite/core/database.dart';
import 'package:flutter_sqlite/features/note/model/note_model.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<Note> notes = [];

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final data = await NoteDatabase.instance.readAll();

    setState(() {
      notes = data;
    });
  }

  Future<void> addNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) return;

    await NoteDatabase.instance.create(
      Note(
        title: title,
        content: content,
      ),
    );

    titleController.clear();
    contentController.clear();

    loadNotes();
  }

  Future<void> updateNote(Note note) async {
    titleController.text = note.title;
    contentController.text = note.content;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Sửa ghi chú'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                ),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                await NoteDatabase.instance.update(
                  Note(
                    id: note.id,
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                  ),
                );

                titleController.clear();
                contentController.clear();

                Navigator.pop(context);
                loadNotes();
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteNote(int id) async {
    await NoteDatabase.instance.delete(id);
    loadNotes();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD SQLite'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: addNote,
              child: const Text('Thêm ghi chú'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];

                  return Card(
                    child: ListTile(
                      title: Text(note.title),
                      subtitle: Text(note.content),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              updateNote(note);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteNote(note.id!);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}