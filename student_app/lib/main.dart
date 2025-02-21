import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Student List')),
        body: const FirestoreData(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showStudentDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showStudentDialog(BuildContext context, [DocumentSnapshot? student]) {
    TextEditingController nameController =
        TextEditingController(text: student?.get('name') ?? '');
    TextEditingController studentIdController =
        TextEditingController(text: student?.get('student_id') ?? '');
    TextEditingController majorController =
        TextEditingController(text: student?.get('major') ?? '');
    TextEditingController yearController =
        TextEditingController(text: student?.get('year') ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(student == null ? 'Add New Student' : 'Edit Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: studentIdController,
                  decoration: const InputDecoration(labelText: 'Student ID')),
              TextField(
                  controller: majorController,
                  decoration: const InputDecoration(labelText: 'Major')),
              TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Year')),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                var data = {
                  'name': nameController.text,
                  'student_id': studentIdController.text,
                  'major': majorController.text,
                  'year': yearController.text,
                };
                if (student == null) {
                  FirebaseFirestore.instance.collection('students').add(data);
                } else {
                  FirebaseFirestore.instance
                      .collection('students')
                      .doc(student.id)
                      .update(data);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class FirestoreData extends StatelessWidget {
  const FirestoreData({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('students').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching data'));
        }
        final data = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            var student = data[index];
            return ListTile(
              title: Text(student['name'] ?? 'No Name'),
              subtitle: Text(
                  '${student['student_id']} - ${student['major']} (Year ${student['year']})'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showStudentDialog(context, student),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => FirebaseFirestore.instance
                        .collection('students')
                        .doc(student.id)
                        .delete(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStudentDialog(BuildContext context, DocumentSnapshot student) {
    (_MainAppState())._showStudentDialog(context, student);
  }
}
