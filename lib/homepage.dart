import 'package:db_practise/data/local/db_helper.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Map<String, dynamic>> allNotes = [];
  final DBHelper dbRef = DBHelper.getInsatnce;

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef.getAllNotes();
    setState(() {});
  }

  void deleteNote(int sno) async {
    await dbRef.deleteNote(sno);
    getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff6A5AE0), Color(0xff9B8CFF)],
            ),
          ),
        ),
        title: const Text(
          "My Notes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                final note = allNotes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 90,
                          decoration: const BoxDecoration(
                            color: Color(0xff6A5AE0),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            title: Text(
                              note[DBHelper.COLUMN_NOTE_TITLE],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                note[DBHelper.COLUMN_NOTE_DESC],
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                _actionButton(
                                  icon: Icons.edit,
                                  color: Colors.blue,
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder: (_) => BottomSheetView(
                                        onNoteAdded: getNotes,
                                        isEdit: true,
                                        sno: note[DBHelper.COLUMN_NOTE_SNO],
                                        oldTitle:
                                            note[DBHelper.COLUMN_NOTE_TITLE],
                                        oldDesc:
                                            note[DBHelper.COLUMN_NOTE_DESC],
                                      ),
                                    );
                                  },
                                ),
                                _actionButton(
                                  icon: Icons.delete,
                                  color: Colors.red,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        title: const Text("Delete Note"),
                                        content: const Text(
                                          "Are you sure you want to delete this note?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              deleteNote(
                                                note[DBHelper.COLUMN_NOTE_SNO],
                                              );
                                            },
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "No notes yet",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Tap + to add your first note"),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff6A5AE0),
        elevation: 8,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => BottomSheetView(onNoteAdded: getNotes),
          );
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class BottomSheetView extends StatefulWidget {
  final VoidCallback onNoteAdded;
  final bool isEdit;
  final int? sno;
  final String? oldTitle;
  final String? oldDesc;

  const BottomSheetView({
    super.key,
    required this.onNoteAdded,
    this.isEdit = false,
    this.sno,
    this.oldTitle,
    this.oldDesc,
  });

  @override
  State<BottomSheetView> createState() => _BottomSheetViewState();
}

class _BottomSheetViewState extends State<BottomSheetView> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final DBHelper dbRef = DBHelper.getInsatnce;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      titleController.text = widget.oldTitle ?? "";
      descController.text = widget.oldDesc ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isEdit ? "Edit Note" : "Add Note",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  final desc = descController.text.trim();

                  if (title.isEmpty || desc.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("All fields are required")),
                    );
                    return;
                  }

                  if (widget.isEdit) {
                    await dbRef.updateNote(
                      mtitle: title,
                      mdesc: desc,
                      sno: widget.sno!,
                    );
                  } else {
                    await dbRef.addNote(mtitle: title, mdesc: desc);
                  }

                  widget.onNoteAdded();
                  Navigator.pop(context);
                },
                child: Text(widget.isEdit ? "Update" : "Add"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
