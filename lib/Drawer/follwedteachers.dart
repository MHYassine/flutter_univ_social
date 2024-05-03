import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Profile/profileWithid.dart';
import '../firebase/tools.dart';

class FollowedTeachersPage extends StatefulWidget {
  const FollowedTeachersPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FollowedTeachersPageState createState() => _FollowedTeachersPageState();
}

class _FollowedTeachersPageState extends State<FollowedTeachersPage> {
  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> followedTeachersData = [];
  final tool = Tools();

  Future<void> _getUserData() async {
    await tool.getUserData(userData, FirebaseAuth.instance.currentUser!.uid);

    final List<String> followingUIDs =
        (userData['FollowingUIDs'] as Iterable<dynamic>)
            .map((e) => e.toString())
            .toList();

    for (final uid in followingUIDs) {
      final Map<String, dynamic> teacherData = {};
      await tool.getUserData(teacherData, uid);
      followedTeachersData.add(teacherData);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getUserData(); // Fetch user data when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followed Teachers'),
      ),
      body: ListView.builder(
        itemCount: followedTeachersData
            .length, // Use the length of followedTeachersData
        itemBuilder: (context, index) {
          final teacherData =
              followedTeachersData[index]; // Get teacher data for current index
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person), // Placeholder for teacher avatar
            ),
            title: Text(
                '${teacherData['firstName']} ${teacherData['lastName']}'), // Use teacher name from teacherData
            trailing: IconButton(
              icon: const Icon(
                  Icons.person), // Change icon based on follow status
              onPressed: () {
                final String uid = teacherData['userId'].toString();
                Navigator.push(
                  context,
                  MaterialPageRoute<Profile2Page>(
                    builder: (context) => Profile2Page(uid: uid),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
