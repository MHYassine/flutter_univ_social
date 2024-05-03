// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../firebase/appstate.dart';
import 'Posting.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) {
        final bool isLoggedIn = appState.loggedIn;
        final bool isStudent = appState.isStudent;
        return Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: const Text('Home'),
                onTap: () {
                  // Navigate to the Home page
                  context.go('/');
                },
              ),
              if (isLoggedIn && !isStudent) ...[
                ListTile(
                  title: const Text('Make a Post'),
                  onTap: () {
                    showDialog<String>(
                      context: context,
                      builder: (context) {
                        return const TeacherPostForm(
                          listOfClasses: ['1IDL', '2IDL', '3IDL'],
                        );
                      },
                    );
                  },
                ),
              ],
              if (isLoggedIn) ...[
                ListTile(
                  title: const Text('Profile'),
                  onTap: () {
                    // Navigate to the Profile page
                    context.go('/profile');
                  },
                ),
                if (isStudent) ...[
                  ListTile(
                    title: const Text('Followed Teachers'),
                    onTap: () {
                      // Navigate to the Followed Teachers page
                      context.go('/Followed');
                    },
                  ),
                ],
                ListTile(
                  title: const Text('Sign Out'),
                  onTap: () {
                    showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content:
                            const Text('Are you sure you want to sign out?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              appState.clearUserData(); // Clear user data
                              FirebaseAuth.instance.signOut();
                              Navigator.of(context).pop();
                              context.go('/'); // Close the dialog
                            },
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ] else ...[
                if (!appState.loggedIn) ...[
                  ListTile(
                    title: const Text('Sign In'),
                    onTap: () {
                      // Navigate to the Sign In page
                      context.go('/sign-in');
                    },
                  ),
                ],
              ],
              const Divider(),
              ListTile(
                title: const Text('Settings'),
                onTap: () {
                  // Navigate to the Settings page
                  context.go('/Settings');
                },
              ),
              ListTile(
                title: const Text('Exit'),
                onTap: () {
                  // Close the app
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
