import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/page/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Registerriders extends StatefulWidget {
  const Registerriders({super.key});

  @override
  State<Registerriders> createState() => _RegisterridersState();
}

class _RegisterridersState extends State<Registerriders> {
  final ImagePicker picker = ImagePicker();
  var db = FirebaseFirestore.instance;

  var nameCtl = TextEditingController();
  var phoneCtl = TextEditingController();
  var passwordCtl = TextEditingController();
  var vehicleNumberCtl = TextEditingController();

  File? image;
  File? imageVehicle ;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 20),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 241, 241, 241),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      // ตัดให้เป็นวงกลม
                      child: (image != null)
                          ? Image.file(
                              File(image!.path),
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: GestureDetector(
                                onTap: addImgProfile, // ฟังก์ชันเลือกภาพ
                                child: Image.asset(
                                  'assets/images/9055425_bxs_image_add_icon.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),

                Container(
                  width: double.infinity, // กำหนดความกว้างเต็มหน้าจอ
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ), // เว้นระยะซ้าย-ขวา
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //name
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "ชื่อ - สกุล",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: TextField(
                          controller: nameCtl,
                          decoration: InputDecoration(
                            filled: true, // ต้องตั้งเป็น true ถึงจะมีพื้นหลัง
                            fillColor: Color.fromARGB(255, 244, 242, 242),
                            hintText: 'ชื่อ - สกุล',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none, // ถ้าไม่อยากให้ขอบ
                            ),
                          ),
                        ),
                      ),


                      //phone
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "เบอร์โทรศัพท์",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: TextField(
                          controller: phoneCtl,
                          decoration: InputDecoration(
                            filled: true, // ต้องตั้งเป็น true ถึงจะมีพื้นหลัง
                            fillColor: Color.fromARGB(255, 244, 242, 242),
                            hintText: 'เบอร์โทรศัพท์',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none, // ถ้าไม่อยากให้ขอบ
                            ),
                          ),
                        ),
                      ),

                      //password
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "รหัสผ่าน",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: TextField(
                          controller: passwordCtl,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true, // ต้องตั้งเป็น true ถึงจะมีพื้นหลัง
                            fillColor: Color.fromARGB(255, 244, 242, 242),
                            hintText: 'รหัสผ่าน',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none, // ถ้าไม่อยากให้ขอบ
                            ),
                          ),
                        ),
                      ),

                      //ทะเบียนรถ
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "ทะเบียนรถ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: TextField(
                          controller: vehicleNumberCtl,
                          decoration: InputDecoration(
                            filled: true, // ต้องตั้งเป็น true ถึงจะมีพื้นหลัง
                            fillColor: Color.fromARGB(255, 244, 242, 242),
                            hintText: 'ทะเบียนรถ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none, // ถ้าไม่อยากให้ขอบ
                            ),
                          ),
                        ),
                      ),

                      //รูปยานพาหนะ
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "รูปยานพาหนะ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: 370,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 241, 241, 241),
                        ),
                        child: Card(
                          child: (imageVehicle  != null)
                              ? Image.file(
                                  File(imageVehicle !.path),
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: GestureDetector(
                                    onTap: addImgVehicle, // ฟังก์ชันเลือกภาพ
                                    child: Image.asset(
                                      'assets/images/9055425_bxs_image_add_icon.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 50),
                        child: Center(
                          child: FilledButton(
                            onPressed: addData,
                            style: FilledButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 255, 187, 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  10,
                                ), // มุมโค้ง
                              ),
                            ),
                            child: Text(
                              "ลงทะเบียน",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void addImgProfile() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    image = File(picked.path);
    setState(() {});
  }

  void addData() async {
    try {
      var docRef = db.collection('riders').doc();
      final hashedPassword = BCrypt.hashpw(passwordCtl.text, BCrypt.gensalt());
      String? imageUrl;
      String? imageUrlVehicle;

      // ถ้ามีภาพจาก addImg() → อัปโหลดก่อน
      if (image != null) {
        imageUrl = await uploadToCloudinary(image!);
        log("imageUrl : $imageUrl");
      } else {
        log("No image");
      }

      if (imageVehicle  != null) {
        imageUrlVehicle = await uploadToCloudinary(imageVehicle !);
        log("imageUrl : $imageUrlVehicle");
      } else {
        log("No image");
      }

      var data = {
        'name': nameCtl.text,
        'phone': phoneCtl.text,
        'password': hashedPassword,
        'createdAt': DateTime.now(),
        'vehicle_number': vehicleNumberCtl.text,
        if (imageUrl != null) 'profile_image': imageUrl,
        if (imageUrlVehicle != null) 'vehicle_image': imageUrlVehicle,
      };

      await docRef.set(data);
      print("${docRef.id} ลงทะเบียนสำเร็จ");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (error) {
      print(error);
    }
  }

  void addImgVehicle() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    imageVehicle  = File(picked.path);
    setState(() {});
  }

  Future<String?> uploadToCloudinary(File imageFile) async {
    try {
      const cloudName = "dsz1hhnx4"; // Cloud name ของคุณ
      const uploadPreset = "flutter_upload"; // ชื่อ preset ที่ตั้งใน Cloudinary

      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      var request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseData);
        return jsonData['secure_url']; // ✅ ได้ URL กลับมา
      } else {
        print("Upload failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }
}
