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
                    return AlertDialog(
                      title: const Text('Add New Data'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                          TextField(
                            controller: studentIdController,
                            decoration: InputDecoration(
                                labelText: 'Student ID',
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
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('students').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text('Error fetching data');
        }
        final data = snapshot.data?.docs.map((doc) => doc.data()).toList();
        return ListView.builder(
          itemCount: data?.length ?? 0,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(data?[index]['name'] ?? 'No data'),
              subtitle: Text(data?[index]['student_id'] ?? 'No data'),
            );
          },
        );
      },
    );
  }
}
