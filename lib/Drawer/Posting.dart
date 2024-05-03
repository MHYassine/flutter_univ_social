import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase/tools.dart';

class TeacherPostForm extends StatefulWidget {
  final List<String> listOfClasses;

  const TeacherPostForm({super.key, required this.listOfClasses});

  @override
  // ignore: library_private_types_in_public_api
  _TeacherPostFormState createState() => _TeacherPostFormState();
}

class _TeacherPostFormState extends State<TeacherPostForm> {
  late TextEditingController _objectController;
  late TextEditingController _contentController;
  List<String> selectedClasses = [];
  Map<String, dynamic> thisuserdata = {};
  final tool = Tools();

  @override
  void initState() {
    super.initState();
    _objectController = TextEditingController();
    _contentController = TextEditingController();
    tool.getUserData(thisuserdata, FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  void dispose() {
    _objectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Post'),
      content: SizedBox(
        width: 400, // Set the width of the dialog
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _objectController,
                decoration: const InputDecoration(labelText: 'Object'),
              ),
              const SizedBox(height: 16),
              const Text('Class'),
              SizedBox(
                height: 200, // Set the height of the class selection list
                child: ListView.builder(
                  itemCount: widget.listOfClasses.length,
                  itemBuilder: (context, index) {
                    final classItem = widget.listOfClasses[index];
                    return CheckboxListTile(
                      title: Text(classItem),
                      value: selectedClasses.contains(classItem),
                      onChanged: (value) {
                        setState(() {
                          if (value != null && value) {
                            selectedClasses.add(classItem);
                          } else {
                            selectedClasses.remove(classItem);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text('Selected Classes: ${selectedClasses.join(', ')}'),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Discard'),
        ),
        ElevatedButton(
          onPressed: () {
            final Map<String, dynamic> postData = {
              'objectController': _objectController.text,
              'contentController': _contentController.text,
              'selectedClasses': selectedClasses,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'PostingId': FirebaseAuth.instance.currentUser!.uid,
              'PosterFullName':
                  '${thisuserdata['firstName']} ${thisuserdata['lastName']}',
            };
            tool.addPost(postData, FirebaseAuth.instance.currentUser!.uid);
            //dispose();
            Navigator.pop(context);
          },
          child: const Text('Post'),
        ),
      ],
    );
  }
}
