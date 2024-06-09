import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Cooperative {
  String id;
  String registrationId;
  String name;
  String description;
//  String provinceLocation;
  String districtLocation;
  String sectorLocation;
  String cellLocation;
  String villageLocation;
  Timestamp timestamp; // Add timestamp field

  Cooperative({
    required this.id,
    required this.registrationId,
    required this.name,
    required this.description,
    
    required this.districtLocation,
    required this.sectorLocation,
    required this.cellLocation,
    required this.villageLocation,
    required this.timestamp,
    required String provinceLoaction, // Initialize timestamp
  });

  // Method to convert Firestore document snapshot to Cooperative object
  factory Cooperative.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Cooperative(
      id: data['id'],
      registrationId: data['registrationId'],
      name: data['name'],
      description: data['description'],
      districtLocation: data['districtLocation'],
      sectorLocation: data['sectorLocation'],
      cellLocation: data['cellLocation'],
      villageLocation: data['villageLocation'],
      timestamp: data['timestamp'],
      provinceLoaction: 'provinceLocation',
      // Assign timestamp
    );
  }

  // Method to convert Cooperative object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'registrationId': registrationId,
      'name': name,
      'description': description,
      //'provinceLocation': provinceLocation,
      'districtLocation': districtLocation,
      'sectorLocation': sectorLocation,
      'cellLocation': cellLocation,
      'villageLocation': villageLocation,
      'timestamp': timestamp, // Include timestamp
    };
  }
}
