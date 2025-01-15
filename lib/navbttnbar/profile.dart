import 'package:chip_pos/styles/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chip_pos/login/login.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String userName = 'Loading...';
  String userEmail = 'Loading...';
  String userRole = 'Loading...';
  String userCreatedAt = 'Loading...';

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      _getUserData();
    }
  }

  Future<void> _getUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        userName = userDoc['name'] ?? 'No Name';
        userEmail = userDoc['email'] ?? 'No Email';
        userRole = userDoc['role'] ?? 'No Role';
        userCreatedAt = userDoc['createdAt'] != null
            ? userDoc['createdAt'].toDate().toString()
            : 'No Date';
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyles.titleApp,
        ),
        backgroundColor: AppColors.bg,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.merah),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    height: 800,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.bg, AppColors.menu],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.start, // Posisi konten di atas
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Foto Profil
                            CircleAvatar(
                              radius: 70.0,
                              backgroundImage: user?.photoURL != null
                                  ? NetworkImage(user!.photoURL!)
                                  : AssetImage(
                                          'assets/images/default_avatar.png')
                                      as ImageProvider,
                            ),
                            SizedBox(height: 20.0),

                            // Nama Pengguna
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10.0),

                            // Email Pengguna
                            Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 10.0),

                            // Role Pengguna
                            Text(
                              'Role: $userRole',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 10.0),

                            // Waktu Pembuatan Akun
                            Text(
                              'Dibuat pada: $userCreatedAt',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 30.0),

                            // Tombol Logout
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
