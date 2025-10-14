import 'dart:developer';

import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/page/homepageRider.dart';
import 'package:delivery/page/homepageUser.dart';
import 'package:delivery/page/registerUsers.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapSend',
      theme: ThemeData(fontFamily: 'Prompt'),
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
    );
  }
}

/// หน้าแรก
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE10A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_delivery.jpg'),
            const SizedBox(height: 16),
            const Text(
              "SnapSend",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 100),
            SizedBox(
              width: 350,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  "เข้าสู่ระบบ",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: 350,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Registerusers(),
                    ),
                  );
                },
                child: const Text("ลงทะเบียน", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  var db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("เข้าสู่ระบบ"),
        backgroundColor: Color.fromARGB(255, 253, 225, 10),
        toolbarHeight: 90,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/images/logo_delivery_login.jpg'),
            const SizedBox(height: 8),
            Text(
              "SnapSend",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFDE10A),
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 40),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                hintText: "เบอร์โทรศัพท์",
                filled: true,
                fillColor: const Color.fromARGB(255, 226, 226, 226),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "รหัสผ่าน",
                filled: true,
                fillColor: const Color.fromARGB(255, 226, 226, 226),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => loginUser(),
                child: const Text(
                  "เข้าสู่ระบบ",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("ยังไม่ได้สมัคร SnapSend? "),
                GestureDetector(
                  onTap: () {
                    //  ไปหน้า Register
                  },
                  child: Text(
                    "ลงทะเบียน",
                    style: TextStyle(
                      color: const Color(0xFFFDE10A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void loginUser() async {
    var phoneInput = phoneController.text.trim();
    log(phoneInput);
    var indexRef = db.collection('users');
    var dbRider = db.collection('riders');

    var query = indexRef.where("phone", isEqualTo: phoneInput);
    var result = await query.get();

    var queryRider = dbRider.where("phone", isEqualTo: phoneInput);
    var resultRider = await queryRider.get();

    if (result.docs.isNotEmpty) {
      var userData = result.docs.first.data();
      var hashedPassword = userData['password'];

      bool userIsMatch = BCrypt.checkpw(
        passwordController.text,
        hashedPassword,
      );

      if (userIsMatch) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePageUser()),
        );
      } else {
        log('รหัสผ่านผิด');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("รหัสผ่านไม่ถูกต้อง"),
            content: const Text("รหัสผ่านไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ปิด dialog
                },
                child: const Text("ปิด"),
              ),
            ],
          ),
        );
      }
    } else if (resultRider.docs.isNotEmpty) {
      var riderData = resultRider.docs.first.data();
      var hashedPasswordRider = riderData['password'];

      bool riderIsMatch = BCrypt.checkpw(
        passwordController.text,
        hashedPasswordRider,
      );

      if (riderIsMatch) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Homepagerider()),
        );
      } else {
        log('รหัสผ่านผิด');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("รหัสผ่านไม่ถูกต้อง"),
            content: const Text("รหัสผ่านไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ปิด dialog
                },
                child: const Text("ปิด"),
              ),
            ],
          ),
        );
      }
    } else {
      log('ไม่มีบัญชีนี้');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("ไม่มีบัญชีนี้"),
          content: const Text("ไม่มีบัญชีนี้ กรุณาลองใหม่อีกครั้ง"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: const Text("ปิด"),
            ),
          ],
        ),
      );
    }
  }
}
