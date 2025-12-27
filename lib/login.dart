import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  Future<void> login() async {
    if (!emailCtrl.text.endsWith(".iitmandi.ac.in")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Use campus email only")));
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text,
        password: passCtrl.text,
      );
    } catch (e) {
      print("SIGN IN ERROR: $e");

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailCtrl.text,
          password: passCtrl.text,
        );
      } catch (e) {
        print("SIGN UP ERROR: $e");
      }
    }


    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("UniTrade", style: TextStyle(fontSize: 32)),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text("Login / Signup")),
          ],
        ),
      ),
    );
  }
}
