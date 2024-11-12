import 'package:chip_pos/styles/stylbttn.dart';
import 'package:chip_pos/styles/style.dart';
import 'package:chip_pos/styles/textstyledec.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chip_pos/main.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isObscure = true;

  Future<void> _login() async {
    try {
      final UserCredential user = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (user.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainMenu()),
        );
      }
    } catch (e) {
      print("Login Error: $e");
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
          // Center content
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '𝓁ℴ𝑔𝒾𝓃',
                    style: TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 81, 81, 54),
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    controller: _emailController,
                    textInputType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    hint: 'Username,Email,No.telp',
                    haSuffix: true,
                    icon: Icons.person,
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
                  SizedBox(height: 50),
                  Bttnstyl(
                    child: ElevatedButton(
                      style: raisedButtonStyle,
                      onPressed: _login,
                      child: SizedBox(
                        width: 320,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Login',
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
                  SizedBox(
                    height: 95,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 112, 80),
                      child: Text(
                        'ˢᵘᵖᵖᵒʳᵗ ᵇʸ ᶜʰⁱᵖ ᴾᵒˢ', // Ganti dengan nama Anda atau perusahaan
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 122, 60, 60),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: Image.asset(
                'assets/images/loginpng.png',
                height: 300, // Sesuaikan tinggi gambar jika diperlukan
                fit: BoxFit.contain, // Agar gambar tidak terdistorsi
              ),
            ),
          ),
        ],
      ),
    );
  }
}
