import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:umutima/pages/admin/formwidgets.dart';
import 'package:uuid/uuid.dart';

class UpdatePage extends StatelessWidget {
  final String registrationId;
  final String name;
  final String description;
  final String districtLocation;
  final String provinceLocation;
  final String sectorLocation;
  final String cellLocation;
  final String villageLocation;

  const UpdatePage(
      {Key? key,
        required this.registrationId,
        required this.name,
        required this.cellLocation,
        required this.description,
        required this.provinceLocation,
        required this.districtLocation,
        required this.sectorLocation,
        required this.villageLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Cooperative'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update Cooperative',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'ID: $registrationId',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 23,
              ),
              Text(
                'Name: $name',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Umudugudu: $villageLocation',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Akagari: $cellLocation',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Umurenge: $sectorLocation',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Akarere: $districtLocation',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Intara: $provinceLocation',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'Intego: $description',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              MemberForm(
                registrationId: registrationId,
                name: name,
                villageLocation: villageLocation,
                cellLocation: cellLocation,
                description: description,
                sectorLocation: sectorLocation,
                districtLocation: districtLocation,
                provinceLocation: provinceLocation,
              ), // Display the member form
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implement form submission functionality
                },
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

