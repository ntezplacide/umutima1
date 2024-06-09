import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model class to represent the fetched data
class MyData {
  final String id;
  final String name;
  final String description;
  final String cellLocation;
  final String districtLocation;
  final String sectorLocation;
  final String village;
  final DateTime timestamp;
  final String registrationId;

  MyData({
    required this.id,
    required this.name,
    required this.description,
    required this.cellLocation,
    required this.districtLocation,
    required this.sectorLocation,
    required this.village,
    required this.timestamp,
    required this.registrationId,
  });

  factory MyData.fromJson(Map<String, dynamic> json) => MyData(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        cellLocation: json['cellLocation'] as String,
        districtLocation: json['districtLocation'] as String,
        sectorLocation: json['sectorLocation'] as String,
        village: json['village'], // Assuming 'village' is present in the data
        timestamp: DateTime.parse(json['timestamp'] as String),
        registrationId: json['registrationId'] as String,
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<MyData?>? fetchData;

  @override
  void initState() {
    super.initState();
    fetchData = _fetchMyData();
  }

  Future<MyData?> _fetchMyData() async {
    // Replace 'YOUR_API_URL' with the actual URL of your API endpoint
    final response = await http.get(Uri.parse('YOUR_API_URL'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MyData.fromJson(data);
    } else {
      // Handle error scenario (e.g., display an error message)
      print('Error fetching data: ${response.statusCode}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetched Data'),
      ),
      body: Center(
        child: FutureBuilder<MyData?>(
          future: fetchData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!;
              return _buildDataDisplay(data);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            // Display a loading indicator while fetching data
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget _buildDataDisplay(MyData data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('ID: ${data.id}'),
        Text('Name: ${data.name}'),
        Text('Description: ${data.description}'),
        Text('Cell Location: ${data.cellLocation}'),
        Text('District Location: ${data.districtLocation}'),
        Text('Sector Location: ${data.sectorLocation}'),
        Text('Village: ${data.village}'), // Assuming 'village' is present
        Text('Timestamp: ${data.timestamp.toString()}'),
        Text('Registration ID: ${data.registrationId}'),
      ],
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Data Fetching Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}
