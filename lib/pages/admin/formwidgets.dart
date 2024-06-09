import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MemberForm extends StatefulWidget {
  final String registrationId;
  final String name;
  final String description;
  final String provinceLocation;
  final String districtLocation;
  final String sectorLocation;
  final String cellLocation;
  final String villageLocation;

  const MemberForm({
    Key? key,
    required this.registrationId,
    required this.name,
    required this.villageLocation,
    required this.cellLocation,
    required this.description,
    required this.provinceLocation,
    required this.districtLocation,
    required this.sectorLocation, required String cooperativeName,
  }) : super(key: key);

  @override
  _MemberFormState createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  final _formKey = GlobalKey<FormState>();
  List<MemberData> members = [];
  Map<String, dynamic> allData = {};

  @override
  void initState() {
    super.initState();
    getAllData();
  }

  Future<void> getAllData() async {
    final String url = 'assets/locations/locations.json';
    try {
      final response = await rootBundle.loadString(url);
      setState(() {
        allData = json.decode(response) as Map<String, dynamic>;
      });
    } catch (error) {
      print(error);
    }
  }

  Future<Map<String, dynamic>> getAllDataInternal() async {
    final String url = 'assets/locations/locations.json';
    try {
      final response = await rootBundle.loadString(url);
      return json.decode(response) as Map<String, dynamic>;
    } catch (error) {
      print(error);
      return {};
    }
  }

  List<String> getProvinces() {
    return allData.keys.toList();
  }

  List<String> getDistricts(String province) {
    try {
      final data = allData[province] as Map<String, dynamic>;
      return data.keys.toList();
    } catch (error) {
      print(error);
      return [];
    }
  }

  List<String> getSectors(String province, String district) {
    try {
      final data = allData[province][district] as Map<String, dynamic>;
      return data.keys.toList();
    } catch (error) {
      print(error);
      return [];
    }
  }

  List<String> getCells(String province, String district, String sector) {
    try {
      final data = allData[province][district][sector] as Map<String, dynamic>;
      return data.keys.toList();
    } catch (error) {
      print(error);
      return [];
    }
  }

  List<String> getVillages(
      String province, String district, String sector, String cell) {
    try {
      final data = allData[province][district][sector][cell] as List<dynamic>;
      return data.cast<String>();
    } catch (error) {
      print(error);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var member in members) member.getForm(allData, this),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                members.add(MemberData());
              });
            },
            child: Text('Add Member'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                _saveMembersToFirebase();
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveMembersToFirebase() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    for (var member in members) {
      String userId = Uuid().v4();

      try {
        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: member.email,
          password: 'Umutima@Rwanda',
        );
        User? user = userCredential.user;

        if (user != null) {
          await user.sendEmailVerification();

          FirebaseFirestore.instance.collection('Abanyamuryangobose').add({
            'fullName': member.fullName,
            'username': member.username,
            'phone': member.phone,
            'email': member.email,
            'nid': member.nid,
            'province': member.province,
            'district': member.district,
            'sector': member.sector,
            'cell': member.cell,
            'village': member.village,
            'registrationId': widget.registrationId,
            'Akarere/Itsinda': widget.districtLocation,
            'umurenge/Itsinda': widget.sectorLocation,
            'Akagari/Itsinda': widget.cellLocation,
            'umudugudu/Itsinda': widget.villageLocation,
            'intego/Isinda': widget.description,
            'name': widget.name,
            'date': Timestamp.now(),
            'UserID': userId,
            'Password': 'Umutima@Rwanda',
            'role': 'user',
            'uid': user.uid,
          }).then((value) {
            print('Member added to Firebase');
          }).catchError((error) {
            print('Failed to add member to Firebase: $error');
          });
        }
      } catch (error) {
        print('Failed to create user: $error');
      }
    }
  }
}

class MemberData {
  String fullName = '';
  String username = '';
  String phone = '';
  String email = '';
  String nid = '';
  String province = '';
  String district = '';
  String sector = '';
  String cell = '';
  String village = '';

  Widget getForm(Map<String, dynamic> allData, _MemberFormState parentState) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'Full Name'),
          onSaved: (value) => fullName = value!,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a full name';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Username'),
          onSaved: (value) => username = value!,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a username';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Phone'),
          onSaved: (value) => phone = value!,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a phone number';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Email'),
          onSaved: (value) => email = value!,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter an email address';
            }
            String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
            RegExp regex = RegExp(pattern);
            if (!regex.hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'National ID'),
          onSaved: (value) => nid = value!,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a national ID';
            }
            return null;
          },
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'Province'),
          items: parentState
              .getProvinces()
              .map<DropdownMenuItem<String>>((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(key),
            );
          }).toList(),
          onChanged: (value) {
            parentState.setState(() {
              province = value!;
              district = '';
              sector = '';
              cell = '';
              village = '';
            });
          },
          value: province.isEmpty ? null : province,
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'District'),
          items: province.isEmpty
              ? []
              : parentState
              .getDistricts(province)
              .map<DropdownMenuItem<String>>((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(key),
            );
          }).toList(),
          onChanged: (value) {
            parentState.setState(() {
              district = value!;
              sector = '';
              cell = '';
              village = '';
            });
          },
          value: district.isEmpty ? null : district,
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'Sector'),
          items: district.isEmpty
              ? []
              : parentState
              .getSectors(province, district)
              .map<DropdownMenuItem<String>>((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(key),
            );
          }).toList(),
          onChanged: (value) {
            parentState.setState(() {
              sector = value!;
              cell = '';
              village = '';
            });
          },
          value: sector.isEmpty ? null : sector,
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'Cell'),
          items: sector.isEmpty
              ? []
              : parentState
              .getCells(province, district, sector)
              .map<DropdownMenuItem<String>>((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(key),
            );
          }).toList(),
          onChanged: (value) {
            parentState.setState(() {
              cell = value!;
              village = '';
            });
          },
          value: cell.isEmpty ? null : cell,
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'Village'),
          items: cell.isEmpty
              ? []
              : parentState
              .getVillages(province, district, sector, cell)
              .map<DropdownMenuItem<String>>((dynamic key) {
            return DropdownMenuItem<String>(
              value: key.toString(),
              child: Text(key.toString()),
            );
          }).toList(),
          onChanged: (value) {
            parentState.setState(() {
              village = value!;
            });
          },
          value: village.isEmpty ? null : village,
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

