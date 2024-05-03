import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_tools.dart';

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
}
