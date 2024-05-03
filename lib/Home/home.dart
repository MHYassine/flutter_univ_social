import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Drawer/MyDrawer.dart';
import '../Profile/profileWithid.dart';
import '../firebase/firebase_tools.dart';
import '../firebase/tools.dart';

import 'postItem.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Map<String, dynamic> postData = {};
  List<Map<String, dynamic>> followedTeachersData = [];
  List<String> followingUIDs = [];
  Map<String, List<Map<String, dynamic>>> postDataMap = {};
  List<Map<String, dynamic>> postDataForUid = [];
  final appState = ApplicationState();
  final tool = Tools();

  Future<void> _getPostData(String uid) async {
    final appState = Provider.of<ApplicationState>(context, listen: false);
    await appState.init();
    if (appState.loggedIn && appState.isStudent) {
      final List<Map<String, dynamic>> postDataForUid =
          await tool.getPostData(uid);
      postDataMap[uid] = postDataForUid;
    } else if (appState.loggedIn && !appState.isStudent) {
      final List<Map<String, dynamic>> postDataForCurrentUser =
          await tool.getPostData(FirebaseAuth.instance.currentUser!.uid);
      postDataMap[FirebaseAuth.instance.currentUser!.uid] =
          postDataForCurrentUser;
    } else {
      final List<Map<String, dynamic>> postDataForUid =
          await tool.getPostData(uid);
      postDataMap[uid] = postDataForUid;
    }
  }

  Future<void> _getUserFollowing() async {
    final appState = Provider.of<ApplicationState>(context, listen: false);
    if (appState.userdata.isNotEmpty &&
        appState.isStudent &&
        followingUIDs.isEmpty) {
      final userData = appState.userdata;
      followingUIDs = (userData['FollowingUIDs'] as Iterable<dynamic>)
          .map((e) => e.toString())
          .toList();
      //print(followingUIDs);
    }
  }

  @override
  void initState() {
    super.initState();
    //_cleardata();
    _init();
  }

  Future<void> _init() async {
    if (appState.loggedIn) {
      await _getUserFollowing();
      if (followingUIDs.isNotEmpty) {
        for (final uid in followingUIDs) {
          await _getPostData(uid);
          postDataForUid.addAll(postDataMap[uid] ?? []);
        }
        setState(() {});
      } else if (!appState.isStudent) {
        await _getPostData(FirebaseAuth.instance.currentUser!.uid);
        postDataForUid
            .addAll(postDataMap[FirebaseAuth.instance.currentUser!.uid] ?? []);
      }
    } else {
      await _getPostData('LFSGYxx7InerQsCQkXltzEC69M62');
      postDataForUid.addAll(postDataMap['LFSGYxx7InerQsCQkXltzEC69M62'] ?? []);
      setState(() {});
    }
  }

  void _cleardata() {
    postData = {};
    followedTeachersData = [];
    followingUIDs = [];
    postDataMap = {};
    postDataForUid = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'University Social Media',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.5,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _cleardata();
              setState(() {});
              //_init();
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              _buildSearchBar(context, appState.fullNameToUidMap),
              const SizedBox(height: 16),
              _buildPostItem(context, appState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(
      BuildContext context, Map<String, String> fullNameToUidMap) {
    final List<String> searchSuggestions = fullNameToUidMap.keys.toList();
    appState.init();
    return Row(
      children: [
        Expanded(
            child: Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return searchSuggestions.where(
              (item) => item
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()),
            );
          },
          onSelected: (item) {
            final String uid = fullNameToUidMap[item] ?? '';
            Navigator.push(
              context,
              MaterialPageRoute<Profile2Page>(
                builder: (context) => Profile2Page(uid: uid),
              ),
            );
          },
        )),
        const SizedBox(width: 16),
        Visibility(
          visible: appState.loggedIn && !appState.isStudent,
          child: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildPostItem(BuildContext context, ApplicationState appState) {
    if (postDataForUid.isNotEmpty) {
      return Expanded(
        child: PostItem(
          postDataList: postDataForUid,
          onTap: () {
            print('Post tapped!');
          },
        ),
      );
    } else {
      if (appState.loggedIn) {
        _init();
      }
      return const SizedBox(height: 16);
    }
  }
}
