import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'tools.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  bool _isStudent = false;
  // ignore: non_constant_identifier_names
  bool get isStudent => _isStudent;
  Map<String, dynamic> userdata = {};
  Map<String, String> fullNameToUidMap = {};

  final tool = Tools();

  Future<DocumentReference> addUser(String firstName, String lastName,
      String email, String userClass, String state, String useruid) {
    return FirebaseFirestore.instance.collection('Users').add(<String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'userclass': userClass,
      'userstate': state,
      'userId': useruid,
      // ignore: inference_failure_on_collection_literal
      'FollowingUIDs': [],
    });
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

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);
    await _getfullNameToUid(fullNameToUidMap);
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        tool.getUserData(
            userdata, FirebaseAuth.instance.currentUser!.uid.toString());
        dynamic stateValue = userdata['userstate'];
        if (stateValue.toString().trim().toLowerCase() == 'student') {
          _isStudent = true;
          notifyListeners();
        }
      } else {
        clearUserData();
      }
      notifyListeners();
    });
  }

  Future<String?> signIn({
    required String email,
    required String password,
    required bool isValid,
  }) async {
    if (!isValid) {
      return null;
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await init();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

// ignore: non_constant_identifier_names
  Future<String> SigningUp({
    required String email,
    required String password,
  }) async {
    var userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.toString().trim(),
      password: password.toString().trim(),
    );
    return userCredential.user!.uid;
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<List<Map<String, dynamic>>> getPostData(String posterId) async {
    await init();

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

  void clearUserData() {
    userdata.clear();
    _isStudent = false;
    _loggedIn = false;
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

  Future<void> _getfullNameToUid(Map<String, String> fullNameToUidMap) async {
    final userDoc = await FirebaseFirestore.instance.collection('Users').get();
    if (userDoc.docs.isNotEmpty) {
      for (var doc in userDoc.docs) {
        final userData = doc.data();
        final String Fullname =
            '${userData['firstName']} ${userData['lastName']}';
        final userId = userData['userId'] as String;

        fullNameToUidMap[Fullname] = userId;
      }
      //print(fullNameToUidMap);
    }
  }
}
