import 'package:flutter/material.dart';

class PasswordDialog extends StatefulWidget {
  final Function(String) onPasswordEntered;

  PasswordDialog({required this.onPasswordEntered});

  @override
  _PasswordDialogState createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  late String _enteredPassword;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter your password'),
      content: TextField(
        obscureText: true,
        onChanged: (value) {
          _enteredPassword = value;
        },
        decoration: InputDecoration(
          hintText: 'Password',
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Submit'),
          onPressed: () {
            widget.onPasswordEntered(_enteredPassword);
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }
}
