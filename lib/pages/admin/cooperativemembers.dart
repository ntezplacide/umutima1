import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CooperativeMember {
  String userID = Uuid().v4(); // Generate unique userID
  String fullName = '';
  String username = '';
  String phone = '';
  String email = '';
  String nid = '';
  String province='';
  String district = '';
  String sector = '';
  String cell = '';
  String village = '';
  String role = 'user'; // Default role is 'user'
  String password = 'Umutima@Rwanda'; // Default password
  DateTime createdDate = DateTime.now();
  String registrationId = '';
}

class NewCooperativeMembers extends StatefulWidget {
  @override
  _NewCooperativeMembersState createState() => _NewCooperativeMembersState();
}

class _NewCooperativeMembersState extends State<NewCooperativeMembers> {
  List<CooperativeMember> members = [];
  late String registrationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Cooperative Members'),
      ),
      body: ListView.builder(
        itemCount: members.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == members.length) {
            return ListTile(
              title: Text('Add Member'),
              onTap: () {
                setState(() {
                  members.add(CooperativeMember());
                });
              },
            );
          } else {
            return CooperativeMemberForm(
              member: members[index],
              onDelete: () {
                setState(() {
                  members.removeAt(index);
                });
              },
              onUpdate: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateMemberForm(
                      member: members[index],
                      onSave: (updatedMember) {
                        saveMemberDetails(updatedMember);
                      },
                      registrationId: registrationId, // Pass registrationId
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void saveMemberDetails(CooperativeMember member) {
    FirebaseFirestore.instance.collection('Abanyamuryangobose').add({
      'userID': member.userID,
      'fullName': member.fullName,
      'username': member.username,
      'phone': member.phone,
      'email': member.email,
      'nid': member.nid,
      'district': member.district,
      'sector': member.sector,
      'cell': member.cell,
      'village': member.village,
      'role': member.role,
      'password': member.password,
      'createdDate': member.createdDate,
      'registrationId': member.registrationId,
    }).then((value) {
      print("Member details saved successfully!");
    }).catchError((error) {
      print("Failed to save member details: $error");
    });
  }
}

class CooperativeMemberForm extends StatelessWidget {
  final CooperativeMember member;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  CooperativeMemberForm({
    required this.member,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Full Name'),
              onChanged: (value) => member.fullName = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Username'),
              onChanged: (value) => member.username = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Phone'),
              onChanged: (value) => member.phone = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) => member.email = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'NID'),
              onChanged: (value) => member.nid = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Province'),
              onChanged: (value) => member.province = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'District'),
              onChanged: (value) => member.district = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Sector'),
              onChanged: (value) => member.sector = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Cell'),
              onChanged: (value) => member.cell = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Village'),
              onChanged: (value) => member.village = value,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onDelete,
                  child: Text('Delete'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onUpdate, // Fixed from onUpdate to onPressed
                  child: Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateMemberForm extends StatelessWidget {
  final CooperativeMember member;
  final String registrationId; // Include registrationId
  final Function(CooperativeMember) onSave;

  UpdateMemberForm({
    required this.member,
    required this.registrationId,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Member Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add form fields to update member details
            TextFormField(
              initialValue: member.fullName,
              decoration: InputDecoration(labelText: 'Full Name'),
              onChanged: (value) => member.fullName = value,
            ),
            TextFormField(
              initialValue: member.username,
              decoration: InputDecoration(labelText: 'Username'),
              onChanged: (value) => member.username = value,
            ),
            TextFormField(
              initialValue: member.phone,
              decoration: InputDecoration(labelText: 'Phone'),
              onChanged: (value) => member.phone = value,
            ),
            TextFormField(
              initialValue: member.email,
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) => member.email = value,
            ),
            TextFormField(
              initialValue: member.nid,
              decoration: InputDecoration(labelText: 'NID'),
              onChanged: (value) => member.nid = value,
            ),
            TextFormField(
              initialValue: member.province,
              decoration: InputDecoration(labelText: 'Province'),
              onChanged: (value) => member.province = value,
            ),
            TextFormField(
              initialValue: member.district,
              decoration: InputDecoration(labelText: 'District'),
              onChanged: (value) => member.district = value,
            ),
            TextFormField(
              initialValue: member.sector,
              decoration: InputDecoration(labelText: 'Sector'),
              onChanged: (value) => member.sector = value,
            ),
            TextFormField(
              initialValue: member.cell,
              decoration: InputDecoration(labelText: 'Cell'),
              onChanged: (value) => member.cell = value,
            ),
            TextFormField(
              initialValue: member.village,
              decoration: InputDecoration(labelText: 'Village'),
              onChanged: (value) => member.village = value,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Save the updated member details
                onSave(member);
                Navigator.pop(context); // Close the form after updating
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
