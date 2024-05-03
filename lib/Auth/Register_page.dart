
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../firebase/firebase_tools.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selectedClass = '';
  String _selectedState = '';

  final List<String> classes = ['1IDL', '2IDL', '3IDL'];
  final List<String> states = ['Student', 'Professor'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),

            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedState.isNotEmpty ? _selectedState : null,
                      items: states.map((stateItem) {
                        return DropdownMenuItem<String>(
                          value: stateItem,
                          child: Text(stateItem),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedState = newValue!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'State'),
                    ),
                  ),
                  Visibility(
                    visible: _selectedState == 'Student',
                    child: Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _selectedClass.isNotEmpty ? _selectedClass : null,
                        items: classes.map((classItem) {
                          return DropdownMenuItem<String>(
                            value: classItem,
                            child: Text(classItem),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedClass = newValue!;
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Class'),
                      ),
                    ),
                  ),
                ],
              ),



            ElevatedButton(
              onPressed: () async {
                // Validate form inputs
                if (_validateForm()) {
                  String uid = await ApplicationState().SigningUp(email: _emailController.text.toString().trim(), password: _passwordController.text.toString().trim());
                  // ignore: use_build_context_synchronously
                  context.pushReplacement('/');
                  await ApplicationState().addUser(_firstNameController.text.toString() ,_lastNameController.text.toString() ,_emailController.text.toString() , _selectedClass.toString() ,_selectedState.toString(),uid  );
                  
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _selectedState.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
        ),
      );
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
