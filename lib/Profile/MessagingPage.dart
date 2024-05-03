import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase/firebase_tools.dart';
import '../firebase/tools.dart';

class MessagingPage extends StatefulWidget {
  final String receiverUID;

  const MessagingPage({
    super.key,
    required this.receiverUID,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  List<dynamic> temp = [];
  final appState = ApplicationState();
  final currentUserUID = FirebaseAuth
      .instance.currentUser!.uid; // Assume the current user's UID is '1'
  String message = '';
  final tool = Tools();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: tool.getMessages(widget.receiverUID, currentUserUID, temp),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error fetching messages'),
          );
        } else {
          // Sort the messages based on timestamp
          temp.sort((a, b) {
            // Extract timestamp strings from messages
            String timestampA = a['timestamp'].toString();
            String timestampB = b['timestamp'].toString();

            // Convert timestamp strings to integers
            int timestampIntA = int.tryParse(timestampA) ?? 0;
            int timestampIntB = int.tryParse(timestampB) ?? 0;

            // Compare timestamps
            return timestampIntB.compareTo(timestampIntA);
          });

          return Scaffold(
            appBar: AppBar(
              title: const Text('Messaging'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: temp.length,
                    itemBuilder: (context, index) {
                      final message = temp[temp.length -
                          index -
                          1]; // Access elements in reverse order
                      final String messageText = message['Message'].toString();
                      final String senderUID = message['senderUID'].toString();
                      final bool isSentByCurrentUser =
                          senderUID != currentUserUID;

                      return MessageBubble(
                        message: messageText,
                        isSentByCurrentUser: isSentByCurrentUser,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Enter your message...',
                          ),
                          onChanged: (value) {
                            // Store the typed message
                            message = value;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          if (message.isNotEmpty) {
                            await tool.sendMessage(
                                widget.receiverUID, currentUserUID, message);
                          }
                          // Clear the message after sending
                          setState(() {
                            message = '';
                            temp = [];
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSentByCurrentUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSentByCurrentUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isSentByCurrentUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
