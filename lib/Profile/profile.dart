import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../firebase/firebase_tools.dart';
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          const Expanded(
            flex: 2,
            child: _TopPortion(),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<ApplicationState>(
                builder: (context, appState, _) {
                  final userData = appState.userdata;
                  appState.init();
                  if (userData.isEmpty) {
                    return const Center(
                      child: Text('User data not found'),
                    );
                  }
                  return Column(
                    children: [
                      Text(
                        "${userData['firstName']} ${userData['lastName']}",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
      if (userData['userclass'].isNotEmpty == true ) ProfileInfoItem('Class', userData['userclass']),
      if (userData['userstate'] != null) ProfileInfoItem('State', userData['userstate']),
      if (userData['email'] != null) ProfileInfoItem('Email', userData['email']),
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
              style: Theme.of(context).textTheme.bodySmall,
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
  const _TopPortion();

  @override
  _TopPortionState createState() => _TopPortionState();
}

class _TopPortionState extends State<_TopPortion> {
  final ImagePicker _picker = ImagePicker();

    Future<void> _pickImage(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List fileBytes = await pickedFile.readAsBytes();
      
      // Get the application state instance using Provider
      final appState = Provider.of<ApplicationState>(context, listen: false);

      // Upload the image file as bytes to Firebase Storage
      await appState.uploadImageToFirebaseStorage(fileBytes, 'profile_images/${FirebaseAuth.instance.currentUser!.uid}.jpg');


    } else {
      print('No image selected.');
    }
  }
  

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
                  child: Consumer<ApplicationState>(
                    builder: (context, appState, _) {
                      final userData = appState.userdata;
                      final imageUrl = userData['imageUrl'];
                      if (imageUrl != null ) {
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
                    },
                  )

                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_a_photo),
                      onPressed: () => _pickImage(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

