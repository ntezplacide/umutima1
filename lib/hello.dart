import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:umutima/models/cooperative.dart';
import 'package:uuid/uuid.dart';

class SeniorDashboard extends StatefulWidget {
  @override
  _SeniorDashboardState createState() => _SeniorDashboardState();
}

class _SeniorDashboardState extends State<SeniorDashboard> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _firstName = '';
  bool _isSidebarExpanded = false;

  bool _isLoading = true;
  bool _showNewsButtons = false;
  bool _showNewCooperativeForm = false;
  bool _showExistingUsersForm = false;
  bool _isExistingUsersVisible = false;
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
      QuerySnapshot querySnapshot = await _firestore
          .collection('Umutima-Ikimina')
          .orderBy('name') // Order by cooperative name
          .get();

      List<String> names = [];
      querySnapshot.docs.forEach((doc) {
        names.add(doc['name']);
      });

      setState(() {
        _cooperativeNames = names;
        _isExistingUsersVisible = true;
      });
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
            return _buildSmallScreen();
          } else {
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
              _buildMenuItem(Icons.format_list_bulleted, 'All'),
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
                                        _showExistingUsersForm = false;
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
                                        _showExistingUsersForm = true;
                                        _showNewCooperativeForm = false;
                                        _fetchCooperativeNames();
                                      });
                                    },
                                    icon: Icon(Icons.people),
                                    label: Text('Existing Users'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (_showNewCooperativeForm)
                            _buildNewCooperativeForm(),
                          if (_showExistingUsersForm) _buildExistingUsersForm(),
                          if (_isExistingUsersVisible) ...[
                            ElevatedButton(
                              onPressed: () {
                                _fetchCooperativeNames();
                              },
                              child: Text('Fetch Cooperative Names'),
                            ),
                            Text(
                              'Cooperative Names:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: _cooperativeNames.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(_cooperativeNames[index]),
                                );
                              },
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

  Widget _buildMenuItem(IconData icon, String title, {Function()? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      onTap: onTap != null ? onTap : () {},
    );
  }

  Widget _buildExistingUsersForm() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Existing Users Form',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          // Form fields
          TextField(
            decoration: InputDecoration(labelText: 'First Name'),
          ),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(labelText: 'Last Name'),
          ),
          // Add a button to submit the form (optional)
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {}, // Handle form submission here
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewCooperativeForm() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Cooperative Form',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          // Add your form fields and buttons here
        ],
      ),
    );
  }
}
