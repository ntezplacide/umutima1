import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleDropdown extends StatefulWidget {
  final String documentId;
  final String currentRole;

  RoleDropdown({required this.documentId, required this.currentRole});

  @override
  _RoleDropdownState createState() => _RoleDropdownState();
}

class _RoleDropdownState extends State<RoleDropdown> {
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.currentRole;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: _selectedRole,
          items: <String>['user', 'admin', 'mentor']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedRole = newValue;
            });
          },
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_selectedRole != null && _selectedRole != widget.currentRole) {
              _updateUserRole(widget.documentId, _selectedRole!);
            }
          },
          child: Text('Update Role'),
        ),
      ],
    );
  }

  void _updateUserRole(String documentId, String newRole) {
    FirebaseFirestore.instance.collection('Abanyamuryangobose').doc(documentId).update({
      'role': newRole,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role updated to $newRole')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update role: $error')));
    });
  }
}
