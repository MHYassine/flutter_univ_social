import 'package:flutter/material.dart';

class PostItem extends StatelessWidget {
  final List<Map<String, dynamic>> postDataList;
  final VoidCallback onTap;

  const PostItem({
    super.key,
    required this.postDataList,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: postDataList.map((postData) {
          final String posterFullName = postData['PosterFullName'].toString();
          final String content = postData['contentController'].toString();
          final String object = postData['objectController'].toString();
          // ignore: inference_failure_on_collection_literal
          final List<dynamic> selectedClasses = (postData['selectedClasses'] ?? []) as List<dynamic>;
          final int timestamp = (postData['timestamp'] ?? 0) as int;

          final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final String formattedDate = '${dateTime.year}-${dateTime.month}-${dateTime.day}';

          return InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const CircleAvatar(
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            posterFullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.account_circle), 
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    object,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Classes: ${selectedClasses.join(', ')}'),
                      Text('Date: $formattedDate'),
                      const SizedBox(height: 8.0),
                      Text(
                        content,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
