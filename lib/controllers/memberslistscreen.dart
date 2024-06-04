import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:umutima/authentication/rolepagedetails.dart';

class AllMembersPage extends StatefulWidget {
  @override
  _AllMembersPageState createState() => _AllMembersPageState();
}

class _AllMembersPageState extends State<AllMembersPage> {
  String searchQuery = '';
  bool showLatestFirst = false;

  String filterName = '';
  String filterProvince = '';
  String filterDistrict = '';
  String filterSector = '';
  String filterCell = '';
  String filterVillage = '';
  String filterRole = '';

  final ScrollController _horizontalScrollController = ScrollController();
  final double _scrollAmount = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Members'),
        actions: [
          IconButton(
            icon: Icon(showLatestFirst ? Icons.access_time : Icons.new_releases),
            onPressed: () {
              setState(() {
                showLatestFirst = !showLatestFirst;
              });
            },
            tooltip: showLatestFirst ? 'Show Oldest First' : 'Show Latest First',
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _openFilterDrawer();
            },
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _horizontalScrollController.animateTo(
                _horizontalScrollController.offset - _scrollAmount,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            tooltip: 'Scroll Left',
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              _horizontalScrollController.animateTo(
                _horizontalScrollController.offset + _scrollAmount,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            tooltip: 'Scroll Right',
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFFFFDD0), // Set the background color here
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Abanyamuryangobose')
                    .orderBy('date', descending: showLatestFirst)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No members found.'));
                  }

                  var members = snapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return (searchQuery.isEmpty ||
                        (data['fullName'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                        (data['name'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                        (data['username'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                        (data['phone'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                        (data['email'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                        (data['nid'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                        (data['role'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                        (data['province'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                        (data['district'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                        (data['sector'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                        (data['cell'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                        (data['village'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase())) &&
                        (filterName.isEmpty || (data['name'] ?? '').toString().toLowerCase().contains(filterName.toLowerCase())) &&
                        (filterProvince.isEmpty || (data['province'] ?? '').toString().toLowerCase().contains(filterProvince.toLowerCase())) &&
                        (filterDistrict.isEmpty || (data['district'] ?? '').toString().toLowerCase().contains(filterDistrict.toLowerCase())) &&
                        (filterSector.isEmpty || (data['sector'] ?? '').toString().toLowerCase().contains(filterSector.toLowerCase())) &&
                        (filterCell.isEmpty || (data['cell'] ?? '').toString().toLowerCase().contains(filterCell.toLowerCase())) &&
                        (filterVillage.isEmpty || (data['village'] ?? '').toString().toLowerCase().contains(filterVillage.toLowerCase())) &&
                        (filterRole.isEmpty || (data['role'] ?? '').toString().toLowerCase().contains(filterRole.toLowerCase()));
                  }).toList();

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _horizontalScrollController,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Full Name')),
                          DataColumn(label: Text('Cooperative')),
                          DataColumn(label: Text('Username')),
                          DataColumn(label: Text('Phone')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('National ID')),
                          DataColumn(label: Text('Province')),
                          DataColumn(label: Text('District')),
                          DataColumn(label: Text('Sector')),
                          DataColumn(label: Text('Cell')),
                          DataColumn(label: Text('Village')),
                          DataColumn(label: Text('Role')),
                        ],
                        rows: members.map((member) {
                          var data = member.data() as Map<String, dynamic>;
                          return DataRow(cells: [
                            DataCell(Text(data['fullName'] ?? '')),
                            DataCell(Text(data['name'] ?? '')),
                            DataCell(Text(data['username'] ?? '')),
                            DataCell(Text(data['phone'] ?? '')),
                            DataCell(Text(data['email'] ?? '')),
                            DataCell(Text(data['nid'] ?? '')),
                            DataCell(Text(data['province'] ?? '')),
                            DataCell(Text(data['district'] ?? '')),
                            DataCell(Text(data['sector'] ?? '')),
                            DataCell(Text(data['cell'] ?? '')),
                            DataCell(Text(data['village'] ?? '')),
                            DataCell(
                              InkWell(
                                onTap: () {
                                  // Handle the click event for the role
                                  _onRoleTap(data['role'], member.id);
                                },
                                child: Text(
                                  data['role'] ?? '',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRoleTap(String? role, String documentId) {
    if (role != null) {
      // Perform your desired action on role tap here.
      // For example, navigate to a new page with details about the role.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoleDetailsPage(role: role, documentId: documentId),
        ),
      );
    }
  }

  void _openFilterDrawer() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Filter by Coop Name'),
                  onChanged: (value) {
                    setState(() {
                      filterName = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Filter by Province'),
                  onChanged: (value) {
                    setState(() {
                      filterProvince = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Filter by District'),
                  onChanged: (value) {
                    setState(() {
                      filterDistrict = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Filter by Sector'),
                  onChanged: (value) {
                    setState(() {
                      filterSector = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Filter by Cell'),
                  onChanged: (value) {
                    setState(() {
                      filterCell = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Filter by Village'),
                  onChanged: (value) {
                    setState(() {
                      filterVillage = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Filter by Role'),
                  onChanged: (value) {
                    setState(() {
                      filterRole = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the drawer
                  },
                  child: Text('Apply Filters'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RoleDetailsPage extends StatelessWidget {
  final String role;
  final String documentId;

  RoleDetailsPage({required this.role, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Role Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current role: $role'),
            SizedBox(height: 20),
            RoleDropdown(documentId: documentId, currentRole: role),
          ],
        ),
      ),
    );
  }
}

