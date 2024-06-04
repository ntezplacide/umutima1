import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:umutima/controllers/memberslistscreen.dart';
import 'package:umutima/models/cooperative.dart';
import 'package:umutima/pages/admin/form.dart';
import 'package:uuid/uuid.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAdminFirstName();
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
          width: 200, // Adjust the width of the sidebar
          decoration: BoxDecoration(
            color: Color(0xFF228B22), // Sidebar background color
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow color
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
              // Sidebar content
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
            color: Color(0xFF6699CC), // Set the background color here
            padding: EdgeInsets.all(24),
            child: Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : SingleChildScrollView(
                      // Wrap SingleChildScrollView here
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (_showNewsButtons) ...[
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
                                    label: Text('Existing Copperative'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (_showNewCooperativeForm)
                            _buildNewCooperativeForm(),
                          if (_isExistingUsersVisible) ...[
                            ElevatedButton(
                              onPressed: () {
                                _fetchCooperativeNames();
                              },
                              child: Text(
                                'Fetch Cooperative Names',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 1, 5, 14),
                                ),
                              ),
                            ),
                            Text(
                              'Cooperative Names:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _cooperativeNames.map((name) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 5),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[
                                              200], // Set your desired background color here
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
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
                          SizedBox(height: 24),
                          Text(
                            'Welcome !',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  Widget _buildNewCooperativeForm() {
    final firebaseId = Uuid().v4(); // Generates a random UUID
    final registrationId = Uuid().v4();
    // Declare TextEditingController for each TextFormField
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final provinceController = TextEditingController();
    final districtController = TextEditingController();
    final sectorController = TextEditingController();
    final cellController = TextEditingController();
    final villageController = TextEditingController();
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
          SizedBox(
            height: 20,
          ),
          Text(
            'Location',
            style: TextStyle(
              fontSize: 19,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: districtController,
            decoration: InputDecoration(labelText: 'Province'),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: districtController,
            decoration: InputDecoration(labelText: 'District'),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: sectorController,
            decoration: InputDecoration(labelText: 'Sector'),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: cellController,
            decoration: InputDecoration(labelText: 'Cell'),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: villageController,
            decoration: InputDecoration(labelText: 'Village'),
          ),
          SizedBox(height: 10),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Create a new cooperative object
              final newCooperative = Cooperative(
                id: firebaseId,
                registrationId: registrationId,
                name: nameController.text,
                description: descriptionController.text,
                provinceLoaction: provinceController.text,
                districtLocation: districtController.text,
                sectorLocation: sectorController.text,
                cellLocation: cellController.text,
                villageLocation: villageController.text,
                timestamp: timestamp,
                //  location: location,
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
                provinceController.clear();
                districtController.clear();
                sectorController.clear();
                cellController.clear();
                villageController.clear();

                // Hide the form
                setState(() {
                  _showNewCooperativeForm = false;
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

  void _handleUpdate(String cooperativeName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Umutima-Ikimina')
          .where('name', isEqualTo: cooperativeName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String registrationId = querySnapshot.docs.first['registrationId'];
        String name = querySnapshot.docs.first['name'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdatePage(
              registrationId: registrationId,
              name: name,
              cellLocation: '',
              description: '',
              districtLocation: '',
              sectorLocation: '',
              villageLocation: '',
              provinceLocation: '',
            ),
          ),
        );
      } else {
        print('No matching document found for $cooperativeName');
      }
    } catch (error) {
      print('Error retrieving registrationId: $error');
    }
  }
}
