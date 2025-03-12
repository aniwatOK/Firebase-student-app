import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

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
        body: Center(
          child: FirestoreData(),
        ),
        floatingActionButton: Builder(
          builder: (BuildContext context) {
            return FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController nameController =
                        TextEditingController();
                    TextEditingController studentIdController =
                        TextEditingController();
                    TextEditingController branchController =
                        TextEditingController();
                    TextEditingController yearController =
                        TextEditingController();
                    return AlertDialog(
                      title: const Text('เพิ่มข้อมูลใหม่'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                                labelText: 'ชื่อ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                          TextField(
                            controller: studentIdController,
                            decoration: InputDecoration(
                                labelText: 'รหัสนักศึกษา',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                          TextField(
                            controller: branchController,
                            decoration: InputDecoration(
                                labelText: 'สาขา',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                          TextField(
                            controller: yearController,
                            decoration: InputDecoration(
                                labelText: 'ชั้นปี',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            var data = {
                              'name': nameController.text,
                              'student_id': studentIdController.text,
                              'branch': branchController.text,
                              'year': yearController.text,
                            };
                            FirebaseFirestore.instance
                                .collection('students')
                                .add(data);
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
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
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text('Error fetching data');
        }
        final data = snapshot.data?.docs ?? [];
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            var student = data[index];
            return ListTile(
              title: Text(student['name'] ?? 'No data'),
              subtitle: Text(
                  'ID: ${student['student_id'] ?? 'No data'}\nBranch: ${student['branch'] ?? 'No data'}\nYear: ${student['year'] ?? 'No data'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      TextEditingController nameController =
                          TextEditingController(text: student['name']);
                      TextEditingController studentIdController =
                          TextEditingController(text: student['student_id']);
                      TextEditingController branchController =
                          TextEditingController(text: student['branch']);
                      TextEditingController yearController =
                          TextEditingController(text: student['year']);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Edit Data'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                      labelText: 'ชื่อ',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                ),
                                TextField(
                                  controller: studentIdController,
                                  decoration: InputDecoration(
                                      labelText: 'รหัสนักศึกษา',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                ),
                                TextField(
                                  controller: branchController,
                                  decoration: InputDecoration(
                                      labelText: 'สาขา',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                ),
                                TextField(
                                  controller: yearController,
                                  decoration: InputDecoration(
                                      labelText: 'ชั้นปี',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  var data = {
                                    'name': nameController.text,
                                    'student_id': studentIdController.text,
                                    'branch': branchController.text,
                                    'year': yearController.text,
                                  };
                                  FirebaseFirestore.instance
                                      .collection('students')
                                      .doc(student.id)
                                      .update(data);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('students')
                          .doc(student.id)
                          .delete();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
