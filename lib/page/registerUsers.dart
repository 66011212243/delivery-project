import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/page/login.dart';
import 'package:delivery/page/mapAddress.dart';
import 'package:delivery/page/registerRiders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class Registerusers extends StatefulWidget {
  const Registerusers({super.key});

  @override
  State<Registerusers> createState() => _RegisterusersState();
}

class _RegisterusersState extends State<Registerusers> {
  var mapController = MapController();
  var db = FirebaseFirestore.instance;
  StreamSubscription? listener;

  final ImagePicker picker = ImagePicker();
  File? image;

  XFile? selectedImage;
  String? imageUrl;

  var nameCtl = TextEditingController();
  var phoneCtl = TextEditingController();
  var passwordCtl = TextEditingController();
  var emailCtl = TextEditingController();

  LatLng? selectedLatLng;
  String? selectedAddress;
  String address = "";

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ลงทะเบียน"),
        backgroundColor: Color.fromARGB(255, 253, 225, 10),
        toolbarHeight: 90,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Loader ขณะโหลด
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // แท็บด้านบน
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TabBar(
                      indicatorColor: Color.fromARGB(255, 255, 187, 2),
                      indicatorSize: TabBarIndicatorSize.tab,

                      tabs: [
                        Tab(
                          child: Text(
                            "ผู้ใช้ทั่วไป",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "ไรเดอร์",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 50,
                                  bottom: 20,
                                ),
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
                                              onTap: addImg, // ฟังก์ชันเลือกภาพ
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
                                width:
                                    double.infinity, // กำหนดความกว้างเต็มหน้าจอ
                                padding: EdgeInsets.symmetric(horizontal: 20),
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
                                      padding: const EdgeInsets.only(
                                        bottom: 20,
                                      ),
                                      child: TextField(
                                        controller: nameCtl,
                                        decoration: InputDecoration(
                                          filled:
                                              true, // ต้องตั้งเป็น true ถึงจะมีพื้นหลัง
                                          fillColor: Color.fromARGB(
                                            255,
                                            244,
                                            242,
                                            242,
                                          ),
                                          hintText: 'ชื่อ - สกุล',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide
                                                .none, // ถ้าไม่อยากให้ขอบ
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
                                      padding: const EdgeInsets.only(
                                        bottom: 20,
                                      ),
                                      child: TextField(
                                        controller: phoneCtl,
                                        decoration: InputDecoration(
                                          filled:
                                              true, // ต้องตั้งเป็น true ถึงจะมีพื้นหลัง
                                          fillColor: Color.fromARGB(
                                            255,
                                            244,
                                            242,
                                            242,
                                          ),
                                          hintText: 'เบอร์โทรศัพท์',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide
                                                .none, // ถ้าไม่อยากให้ขอบ
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
                                      padding: const EdgeInsets.only(
                                        bottom: 20,
                                      ),
                                      child: TextField(
                                        controller: passwordCtl,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          filled:
                                              true, // ต้องตั้งเป็น true ถึงจะมีพื้นหลัง
                                          fillColor: Color.fromARGB(
                                            255,
                                            244,
                                            242,
                                            242,
                                          ),
                                          hintText: 'รหัสผ่าน',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide
                                                .none, // ถ้าไม่อยากให้ขอบ
                                          ),
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "ที่อยู่",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    Column(
                                      children: [
                                        Container(
                                          width: 360,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              227,
                                              227,
                                              227,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),

                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 20,
                                              ),
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis
                                                    .horizontal, // เลื่อนแนวนอน
                                                child: Text(
                                                  selectedAddress ??
                                                      "กรุณาเลือกที่อยู่",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            width: 360,
                                            height: 350,
                                            child: FlutterMap(
                                              mapController: mapController,
                                              options: MapOptions(
                                                initialCenter: LatLng(
                                                  16.246373,
                                                  103.251827,
                                                ),
                                                initialZoom: 15.2,
                                                onTap: (tapPosition, point) async {
                                                  setState(() {
                                                    selectedLatLng =
                                                        point; // เก็บพิกัดที่กดเลือก
                                                  });
                                                  List<Placemark> placemarks =
                                                      await placemarkFromCoordinates(
                                                        point.latitude,
                                                        point.longitude,
                                                      );

                                                  if (placemarks.isNotEmpty) {
                                                    final place =
                                                        placemarks.first;

                                                    // ประกอบ address เอง
                                                    address =
                                                        "${place.street ?? ''} "
                                                        "${place.subLocality ?? ''} "
                                                        "${place.locality ?? ''} "
                                                        "${place.subAdministrativeArea ?? ''} "
                                                        "${place.administrativeArea ?? ''} "
                                                        "${place.postalCode ?? ''} "
                                                        "${place.country ?? ''}";
                                                  }
                                                  log("${address}");
                                                  log("${selectedLatLng}");

                                                  // ถ้าต้องการโชว์ในหน้า UI
                                                  setState(() {
                                                    selectedAddress = address;
                                                  });
                                                },
                                              ),
                                              children: [
                                                TileLayer(
                                                  urlTemplate:
                                                      'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=1ef19f91909b4ac1ad3dfb1dc523a2c6',
                                                  userAgentPackageName:
                                                      'com.example.delivery',
                                                ),
                                                if (selectedLatLng !=
                                                    null) // วางหมุดเฉพาะเมื่อมีค่าพิกัด
                                                  MarkerLayer(
                                                    markers: [
                                                      Marker(
                                                        point: selectedLatLng!,
                                                        width: 40,
                                                        height: 40,
                                                        child: Icon(
                                                          Icons.location_on,
                                                          color: Colors.red,
                                                          size: 40,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 50,
                                      ),
                                      child: Center(
                                        child: FilledButton(
                                          onPressed: () => addData(),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Color.fromARGB(
                                              255,
                                              255,
                                              187,
                                              2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    10,
                                                  ), // มุมโค้ง
                                            ),
                                          ),
                                          child: Text(
                                            "ลงทะเบียน",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
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

                        //Tab2
                        Registerriders(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void getMap() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Registerusers()),
    );
  }

  Future<String> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // คุณสามารถเลือกว่าจะใช้ city, street, name หรือ combination
        return "${place.street}, ${place.subLocality}, ${place.locality}";
      }
      return "ไม่พบที่อยู่";
    } catch (e) {
      return "เกิดข้อผิดพลาด: $e";
    }
  }

  Future<void> addData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var docRef = db.collection('users').doc();
      var docAddress = db.collection('address').doc();
      final hashedPassword = BCrypt.hashpw(passwordCtl.text, BCrypt.gensalt());

      final userId = docRef.id;
      String? imageUrl;

      // ถ้ามีภาพจาก addImg() → อัปโหลดก่อน
      if (image != null) {
        imageUrl = await uploadToCloudinary(image!);
        log("imageUrl : $imageUrl");
      } else {
        log("No image");
      }

      var data = {
        'name': nameCtl.text,
        'phone': phoneCtl.text,
        'password': hashedPassword,
        if (imageUrl != null) 'profile_image': imageUrl,
        'createdAt': DateTime.now(),
      };

      var addressData = {
        'user_id': docRef.id,
        'address': selectedAddress,
        'latitude': selectedLatLng!.latitude,
        'longitude': selectedLatLng!.longitude,
      };

      print("Data to upload: $data");
      await docRef.set(data);
      await docAddress.set(addressData);
      print("${docRef.id} ลงทะเบียนสำเร็จ");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (error) {
      print(error);
    }
  }

  void addImg() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    image = File(picked.path);
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

  void readData() async {
    DocumentSnapshot result = await db
        .collection('users')
        .doc(passwordCtl.text)
        .get();
    var data = result.data();
    log(data.toString());
  }

  void queryData() async {
    var indexRef = db.collection('users');
    var query = indexRef.where("name", isEqualTo: nameCtl.text);
    var result = await query.get();
    if (result.docs.isNotEmpty) {
      log(result.docs.first.data()['name']);
    }
  }

  void startRealtime() async {
    final docRef = db.collection("users").doc(passwordCtl.text);
    if (listener != null) {
      await listener!.cancel();
      listener = null;
    }
    listener = docRef.snapshots().listen((event) {
      var data = event.data();
      Get.snackbar(data!.toString(), data!.toString());
      log("current data: ${event.data()}");
    }, onError: (error) => log("Listen failed: $error"));
  }

  void stopRealtime() async {
    try {
      if (listener != null) {
        await listener!.cancel();
        listener = null;
      }
    } catch (e) {
      log('Listener is not running...');
    }
  }
}
