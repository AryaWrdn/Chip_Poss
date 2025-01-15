import 'package:chip_pos/login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chip_pos/styles/stylbttn.dart';
import 'package:chip_pos/styles/style.dart';
import 'package:chip_pos/styles/textstyledec.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool isObscure = true;

  Future<void> _register() async {
    try {
      // Buat user di Firebase Authentication
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Simpan data pengguna ke Firestore dengan role default 'user'
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'name': _nameController.text.trim(),
          'role': 'user', // Role default
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Navigasi ke halaman login atau dashboard
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("Register Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register gagal: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 163, 161, 153),
      body: Stack(
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                        255, 157, 138, 88), // Ubah warna sesuai keinginan
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(500),
                      topLeft: Radius.circular(500),
                    ),
                    border: Border.all(
                      color: AppColors.appbar, // Warna border sesuai keinginan
                      width: 1.0, // Lebar border
                    ),
                  ),
                ),
                Container(
                  height: 750,
                  decoration: BoxDecoration(
                    color: AppColors.bg, // Ubah warna sesuai keinginan
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(500),
                      topLeft: Radius.circular(500),
                    ),
                    border: Border.all(
                      color: AppColors.appbar, // Warna border sesuai keinginan
                      width: 1.0, // Lebar border
                    ),
                  ),
                ),
              ],
            ),
          ]),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '𝓇ℯ𝑔𝒾𝓈𝓉ℯ𝓇',
                    style: TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 81, 81, 54),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _nameController,
                    textInputType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    hint: 'Name',
                    haSuffix: true,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16.0),
                  CustomTextField(
                    controller: _emailController,
                    textInputType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    hint: 'Email',
                    haSuffix: true,
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 16.0),
                  CustomTextField(
                    controller: _passwordController,
                    textInputType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    hint: 'Password',
                    isObscure: isObscure,
                    haSuffix: true,
                  ),
                  const SizedBox(height: 50),
                  Bttnstyl(
                    child: ElevatedButton(
                      style: raisedButtonStyle,
                      onPressed: _register,
                      child: SizedBox(
                        width: 320,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Register',
                            textAlign: TextAlign.center,
                            style: TextStyles.title.copyWith(
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: Text("Back To Login"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
