import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../firebase/firebase_tools.dart';
import '../firebase/tools.dart';
import 'MessagingPage.dart';

class Profile2Page extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const Profile2Page({Key? key, required this.uid});

  final String uid;

  @override
  // ignore: library_private_types_in_public_api
  _Profile2PageState createState() => _Profile2PageState();
}

class _Profile2PageState extends State<Profile2Page> {
  Map<String, dynamic> userData = {};
  List<String> followingUIDs = [];
  bool isFollowing = false;
  final tool = Tools();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final appState = ApplicationState();
    await appState.init();
    await tool.getUserData(userData, widget.uid);
    final thisusedata = appState.userdata;

    if (appState.loggedIn) {
      followingUIDs = (thisusedata['FollowingUIDs'] as Iterable<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      isFollowing = followingUIDs.contains(widget.uid);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _TopPortion(userData: userData),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<ApplicationState>(
                builder: (context, appState, _) {
                  if (userData.isEmpty) {
                    return const Center(
                      child: Text('User data not found'),
                    );
                  }
                  return Column(
                    children: [
                      Text(
                        "${userData['firstName']} ${userData['lastName']}",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton.extended(
                            onPressed: () {
                              if (appState.loggedIn) {
                                if (isFollowing) {
                                  appState.removeFollowing(widget.uid);
                                  isFollowing = false;
                                  setState(() {});
                                } else {
                                  appState.addFollowing(widget.uid);
                                  isFollowing = true;
                                  setState(() {});
                                }
                              } else {
                                print('login please');
                              }
                            },
                            heroTag: 'follow',
                            elevation: 0,
                            label: Text(isFollowing ? 'Following' : 'Follow'),
                            icon: Icon(isFollowing
                                ? Icons.check
                                : Icons.person_add_alt_1),
                          ),
                          const SizedBox(width: 16.0),
                          FloatingActionButton.extended(
                            onPressed: () {
                              if (appState.loggedIn) {
                                String temp = userData['userId'].toString();
                                Navigator.push(
                                  context,
                                  // ignore: inference_failure_on_instance_creation
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MessagingPage(receiverUID: temp),
                                  ),
                                );
                              } else {
                                print('login please');
                              }
                            },
                            heroTag: 'message',
                            elevation: 0,
                            backgroundColor: Colors.red,
                            label: const Text('Message'),
                            icon: const Icon(Icons.message_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ProfileInfoRow(userData: userData),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.userData});

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    final List<ProfileInfoItem> items = [
      if (userData['userclass'].isNotEmpty == true)
        ProfileInfoItem('Class', userData['userclass']),
      if (userData['userstate'] != null)
        ProfileInfoItem('State', userData['userstate']),
      if (userData['email'] != null)
        ProfileInfoItem('Email', userData['email']),
    ];

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(
              item.title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            subtitle: Text(
              item.value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileInfoItem {
  final String title;
  final dynamic value;
  const ProfileInfoItem(this.title, this.value);
}

class _TopPortion extends StatefulWidget {
  final Map<String, dynamic> userData;

  const _TopPortion({required this.userData});

  @override
  _TopPortionState createState() => _TopPortionState();
}

class _TopPortionState extends State<_TopPortion> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xff0043ba), Color(0xff006df1)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: _buildProfileImage(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    final imageUrl = widget.userData['imageUrl'];
    if (imageUrl != null) {
      return Image.network(
        imageUrl.toString(),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return const CircularProgressIndicator();
        },
        errorBuilder: (context, error, stackTrace) {
          return const Text('Error loading image');
        },
      );
    } else {
      return const SizedBox(); // Placeholder when imageUrl is null or empty
    }
  }
}
