import 'package:flutter/material.dart';

class EmailDialog extends StatefulWidget {
  final Function(String) onEmailEntered;

  EmailDialog({required this.onEmailEntered});

  @override
  _EmailDialogState createState() => _EmailDialogState();
}

class _EmailDialogState extends State<EmailDialog> {
  late String _enteredEmail;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter your new email'),
      content: TextField(
        onChanged: (value) {
          _enteredEmail = value;
        },
        decoration: InputDecoration(
          hintText: 'Email',
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Submit'),
          onPressed: () {
            widget.onEmailEntered(_enteredEmail);
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }
}
