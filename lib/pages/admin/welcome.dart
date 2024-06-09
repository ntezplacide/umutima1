import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:umutima/controllers/memberslistscreen.dart';
import 'package:umutima/models/cooperative.dart';
import 'package:umutima/pages/admin/cooperativemembers.dart';
import 'package:umutima/src/pages/updateforms/addingmembers.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class SeniorDashboard extends StatefulWidget {
  @override
  _SeniorDashboardState createState() => _SeniorDashboardState();
}

class _SeniorDashboardState extends State<SeniorDashboard> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _firstName = '';
  bool _isLoading = true;
  bool _showNewsButtons = false;
  bool _showNewCooperativeForm = false;
  bool _isExistingUsersVisible = false;
  bool _showMemberList = false;
  List<String> _cooperativeNames = [];
  Map<String, dynamic> allData = {};
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSector;
  String? selectedCell;
  String? selectedVillage;
  String _errorMessage = '';
  bool _showLoginForm = false;
  String _loginFirstName = '';
  String _loginLastName = '';
 



  @override
  void initState() {
    super.initState();
    _loadAdminFirstName();
    _getAllData();
  }
  

  Future<void> _loadAdminFirstName() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('umutimausers').doc(userId).get();
        if (userSnapshot.exists) {
          setState(() {
            _firstName = userSnapshot['firstName'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          print('User document does not exist');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        print('User ID is null');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading admin first name: $error');
    }
  }

  Future<void> _fetchCooperativeNames() async {
    try {
      QuerySnapshot cooperativeSnapshot =
          await _firestore.collection('Umutima-Ikimina').get();
      if (cooperativeSnapshot.docs.isNotEmpty) {
        List<String> names = [];
        cooperativeSnapshot.docs.forEach((doc) {
          names.add(doc['name']);
        });
        setState(() {
          _cooperativeNames = names;
          _isExistingUsersVisible = true;
        });
      }
    } catch (error) {
      print('Error fetching cooperative names: $error');
    }
  }

  Future<void> _getAllData() async {
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

  List<String> _getProvinces() {
    return allData.keys.toList();
  }

  List<String> _getDistricts(String province) {
    try {
      final data = allData[province] as Map<String, dynamic>;
      return data.keys.toList();
    } catch (error) {
      print(error);
      return [];
    }
  }

  List<String> _getSectors(String province, String district) {
    try {
      final data = allData[province][district] as Map<String, dynamic>;
      return data.keys.toList();
    } catch (error) {
      print(error);
      return [];
    }
  }

  List<String> _getCells(String province, String district, String sector) {
    try {
      final data = allData[province][district][sector] as Map<String, dynamic>;
      return data.keys.toList();
    } catch (error) {
      print(error);
      return [];
    }
  }

  List<String> _getVillages(String province, String district, String sector, String cell) {
    try {
      final data = allData[province][district][sector][cell] as List<dynamic>;
      return data.cast<String>();
    } catch (error) {
      print(error);
      return [];
    }
  }

  Future<bool> _isCooperativeNameExists(String name) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Umutima-Ikimina')
          .where('name', isEqualTo: name)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking cooperative name: $error');
      return false;
    }
  }void _handleUpdate(String name) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MyData(name: name, id: '',, description: '', cellLocation: '', districtLocation: '', sectorLocation: '', village: '', registrationId: '', timestamp: null,),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Senior Dashboard'),
        actions: <Widget>[
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Hello, $_firstName',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.person),
                    ],
                  ),
                ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 600) {
            // For small screens (e.g., mobile devices)
            return _buildSmallScreen();
          } else {
            // For large screens (e.g., laptops, desktops)
            return _buildLargeScreen();
          }
        },
      ),
    );
  }

  Widget _buildLoginForm() {
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
     
      SizedBox(height: 20),
    
      
    ],
  );
}


  Widget _buildSmallScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Content for small screens
        ],
      ),
    );
  }

Widget _buildLargeScreen() {
  return Row(
    children: <Widget>[
      Container(
        width: 200,
        decoration: BoxDecoration(
          color: Color(0xFF228B22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildMenuItem(Icons.home, 'Home'),
            _buildMenuItem(Icons.add, 'New', onTap: () {
              setState(() {
                _showNewsButtons = !_showNewsButtons;
              });
            }),
            _buildMenuItem(Icons.format_list_bulleted, 'All', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllMembersPage()),
              );
            }),
            _buildMenuItem(Icons.analytics_sharp, 'Transaction'),
            _buildMenuItem(Icons.analytics, 'Analysis'),
          ],
        ),
      ),
      Expanded(
        child: Container(
          color: Color(0xFF6699CC),
          padding: EdgeInsets.all(24),
          child: Center(
            child: _isLoading
                ? CircularProgressIndicator()
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (_showLoginForm) _buildLoginForm(),
                        if (_showNewsButtons && !_showLoginForm) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showNewCooperativeForm = true;
                                    });
                                  },
                                  icon: Icon(Icons.group_add),
                                  label: Text('New Cooperative'),
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _fetchCooperativeNames();
                                    });
                                  },
                                  icon: Icon(Icons.people),
                                  label: Text('Existing Cooperative'),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ],
                        if (_showNewCooperativeForm && !_showLoginForm)
                          _buildNewCooperativeForm(),
                        if (_isExistingUsersVisible && !_showLoginForm) ...[
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              _fetchCooperativeNames();
                            },
                            child: Text(
                              'Fetch Cooperative Names',
                              style: TextStyle(
                                color: Color.fromARGB(255, 14, 12, 1),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Cooperative Names:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _cooperativeNames.map((name) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                    height: 23,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _handleUpdate(name);
                                    },
                                    child: Text('Update'),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      ),
    ],
  );
}

   Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _buildNewCooperativeForm() {
    final firebaseId = Uuid().v4(); // Generates a random UUID
    final registrationId = Uuid().v4();
    // Declare TextEditingController for each TextFormField
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final timestamp = Timestamp.now();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          Text(
            'New Cooperative Form',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          if (_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 10),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Cooperative Name'),
          ),
          SizedBox(height: 18),
          TextFormField(
            controller: descriptionController,
            maxLines: null, // Allows multiple lines
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Enter description here...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Location',
            style: TextStyle(
              fontSize: 19,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Province'),
            items: _getProvinces().map<DropdownMenuItem<String>>((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(key),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedProvince = value!;
                selectedDistrict = null;
                selectedSector = null;
                selectedCell = null;
                selectedVillage = null;
              });
            },
            value: selectedProvince,
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'District'),
            items: selectedProvince == null
                ? []
                : _getDistricts(selectedProvince!)
                    .map<DropdownMenuItem<String>>((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),
                    );
                  }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDistrict = value!;
                selectedSector = null;
                selectedCell = null;
                selectedVillage = null;
              });
            },
            value: selectedDistrict,
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Sector'),
            items: selectedDistrict == null
                ? []
                : _getSectors(selectedProvince!, selectedDistrict!)
                    .map<DropdownMenuItem<String>>((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),
                    );
                  }).toList(),
            onChanged: (value) {
              setState(() {
                selectedSector = value!;
                selectedCell = null;
                selectedVillage = null;
              });
            },
            value: selectedSector,
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Cell'),
            items: selectedSector == null
                ? []
                : _getCells(selectedProvince!, selectedDistrict!, selectedSector!)
                    .map<DropdownMenuItem<String>>((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),
                    );
                  }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCell = value!;
                selectedVillage = null;
              });
            },
            value: selectedCell,
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Village'),
            items: selectedCell == null
                ? []
                : _getVillages(selectedProvince!, selectedDistrict!, selectedSector!, selectedCell!)
                    .map<DropdownMenuItem<String>>((dynamic key) {
                    return DropdownMenuItem<String>(
                      value: key.toString(),
                      child: Text(key.toString()),
                    );
                  }).toList(),
            onChanged: (value) {
              setState(() {
                selectedVillage = value!;
              });
            },
            value: selectedVillage,
          ),
          SizedBox(height: 10),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final newCooperativeName = nameController.text;

              // Check if the cooperative name already exists
              bool nameExists = await _isCooperativeNameExists(newCooperativeName);
              if (nameExists) {
                setState(() {
                  _errorMessage = 'Izina Ryarafashwe shaka irindi zina'; // The name is taken, choose another name
                });
                return;
              }

              // Create a new cooperative object
              final newCooperative = Cooperative(
                id: firebaseId,
                registrationId: registrationId,
                name: newCooperativeName,
                description: descriptionController.text,
                provinceLoaction: selectedProvince!,
                districtLocation: selectedDistrict!,
                sectorLocation: selectedSector!,
                cellLocation: selectedCell!,
                villageLocation: selectedVillage!,
                timestamp: timestamp,
              );

              // Save the cooperative data to Firestore
              _firestore
                  .collection('Umutima-Ikimina')
                  .doc(newCooperative.id)
                  .set(newCooperative.toMap())
                  .then((_) {
                // Reset the text controllers
                nameController.clear();
                descriptionController.clear();

                // Hide the form
                setState(() {
                  _showNewCooperativeForm = false;
                  _errorMessage = '';
                });

                // Optionally, show a success message or navigate to a new screen
              }).catchError((error) {
                // Handle errors
                print('Failed to add cooperative: $error');
                // Optionally, show an error message
              });
            },
            child: Text('Submit'),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
