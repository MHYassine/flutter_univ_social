import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'appstate.dart';

class Tools {
  Future<void> getUserData(
      Map<String, dynamic> thisuserdata, String uid) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .where('userId', isEqualTo: uid)
        .get();
    if (userDoc.docs.isNotEmpty) {
      final userData = userDoc.docs.first.data();
      thisuserdata.addAll(userData);
    }
  }

  Future<void> sendMessage(
    String senderUID,
    String recieverUID,
    String message,
  ) async {
    List<dynamic> messages = [];
    await getMessages(senderUID, recieverUID, messages);
    Map<String, dynamic> messageMap = {
      'Message': message,
      'senderUID': senderUID,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    messages.add(messageMap);

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Messages')
        .where('UIDs', isEqualTo: [senderUID, recieverUID]).get();

    if (querySnapshot.docs.isNotEmpty) {
      final documentID = querySnapshot.docs.first.id;

      await FirebaseFirestore.instance
          .collection('Messages')
          .doc(documentID)
          .update({
        'messages': messages,
      });
    } else {
      final querySnapshot2 = await FirebaseFirestore.instance
          .collection('Messages')
          .where('UIDs', isEqualTo: [recieverUID, senderUID]).get();
      if (querySnapshot2.docs.isNotEmpty) {
        final documentID = querySnapshot2.docs.first.id;

        await FirebaseFirestore.instance
            .collection('Messages')
            .doc(documentID)
            .update({
          'messages': messages,
        });
      } else {
        await FirebaseFirestore.instance.collection('Messages').add({
          'UIDs': [senderUID, recieverUID],
          'messages': messages,
        });
      }
    }
  }

  Future<void> getMessages(
    String senderUID,
    String recieverUID,
    List<dynamic> messages,
  ) async {
    final appSate = ApplicationState();
    await appSate.init();
    final userDoc = await FirebaseFirestore.instance
        .collection('Messages')
        .where('UIDs', isEqualTo: [senderUID, recieverUID]).get();

    if (userDoc.docs.isNotEmpty) {
      final userMsg = userDoc.docs.first.data();
      if (userMsg.containsKey('messages')) {
        final retrievedMessages = userMsg['messages'];
        if (retrievedMessages is List<dynamic>) {
          messages.addAll(retrievedMessages);
        }
      }
    } else {
      final userDoc2 = await FirebaseFirestore.instance
          .collection('Messages')
          .where('UIDs', isEqualTo: [recieverUID, senderUID]).get();
      if (userDoc2.docs.isNotEmpty) {
        final userMsg = userDoc2.docs.first.data();
        if (userMsg.containsKey('messages')) {
          final retrievedMessages = userMsg['messages'];
          if (retrievedMessages is List<dynamic>) {
            messages.addAll(retrievedMessages);
          }
        }
      }
    }
  }

  Future<void> addPost(Map<String, dynamic> postData, String posterId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Posts')
        .where('PosterId', isEqualTo: posterId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance.collection('Posts').doc(docId).update({
        'posts': FieldValue.arrayUnion([postData])
      });
    } else {
      await FirebaseFirestore.instance.collection('Posts').add({
        'PosterId': posterId,
        'posts': [postData],
      });
    }
  }

  Future<String?> uploadImageToFirebaseStorage(
      Uint8List fileBytes, String imagePath) async {
    try {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child(imagePath);
      final UploadTask uploadTask = storageRef.putData(fileBytes);
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final DocumentSnapshot userDoc = querySnapshot.docs.first;
        await userDoc.reference.update({'imageUrl': downloadUrl});
      } else {
        //print('User document not found for UID: ${FirebaseAuth.instance.currentUser!.uid}');
      }
      return downloadUrl;
    } catch (e) {
      //print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> addFollowing(String uid) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot userDoc = querySnapshot.docs.first;
      final userData = userDoc.data() as Map<String, dynamic>;

      List<String> uids = [];
      if (userData.containsKey('FollowingUIDs')) {
        final followingUIDs = userData['FollowingUIDs'];
        if (followingUIDs is Iterable) {
          uids.addAll(followingUIDs.cast<String>());
        }
      }
      uids.add(uid);
      await userDoc.reference.update({'FollowingUIDs': uids});
    } else {
      //print('User document not found for UID: ${FirebaseAuth.instance.currentUser!.uid}');
    }
  }

  Future<void> removeFollowing(String uid) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot userDoc = querySnapshot.docs.first;
      final userData = userDoc.data() as Map<String, dynamic>;

      if (userData.containsKey('FollowingUIDs')) {
        final followingUIDs = userData['FollowingUIDs'];
        followingUIDs.remove(uid);
        await userDoc.reference.update({'FollowingUIDs': followingUIDs});
      }
    } else {
      //print('User document not found for UID: ${FirebaseAuth.instance.currentUser!.uid}');
    }
  }

  Future<List<Map<String, dynamic>>> getPostData(String posterId) async {
    final appState = ApplicationState();
    await appState.init();

    final List<Map<String, dynamic>> postDataList = [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Posts')
        .where('PosterId', isEqualTo: posterId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (final doc in querySnapshot.docs) {
        final postDataArray = doc['posts'] as List<dynamic>;
        postDataList.addAll(postDataArray.cast<Map<String, dynamic>>());
      }
    }
    return postDataList;
  }
}
