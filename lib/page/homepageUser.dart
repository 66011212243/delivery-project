import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/page/HistoryUser.dart';
import 'package:delivery/page/Receive.dart';
import 'package:delivery/page/profileUser.dart';
import 'package:delivery/page/Product_details.dart';
import 'package:delivery/page/Shipping.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class HomePageUser extends StatefulWidget {
  String uid = '';
  HomePageUser({super.key, required this.uid});

  @override
  State<HomePageUser> createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text('หน้าหลัก')),
    Center(child: Text('ประวัติการส่ง')),
    Center(child: Text('ที่ต้องได้รับ')),
    Center(child: Text('อื่นๆ')),
  ];

   var db = FirebaseFirestore.instance;
  StreamSubscription? listenerShipping;
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getOrder();
  }

void getOrder() async {
    setState(() {
      isLoading = true; // เริ่มโหลด
    });
    final docOrder = db
        .collection("orders")
        .where("sender_id", isEqualTo: widget.uid)
        .where("status", isLessThan: 4);

    var userDoc = db.collection('users');
    var addressDoc = db.collection('address');
    if (listenerShipping != null) {
      await listenerShipping!.cancel();
      listenerShipping = null;
    }

    listenerShipping = docOrder.snapshots().listen((querySnapshot) async {
      List<Map<String, dynamic>> tempList = [];
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        var senderId = data['sender_id'];
        var receiverId = data['receiver_id'];
        var senderAddress = data['sender_address_id'];
        var receiverAddress = data['receiver_address_id'];

        var userQuerySender = await userDoc.doc(senderId).get();
        var userQueryReceiver = await userDoc.doc(receiverId).get();
        var addressSender = await addressDoc.doc(senderAddress).get();
        var addressReceiver = await addressDoc.doc(receiverAddress).get();

        var senderData = userQuerySender.data();
        var receiverData = userQueryReceiver.data();
        var senderAddressData = addressSender.data();
        var receiverAddressData = addressReceiver.data();

        var senderAddressString = await getAddressFromLatLng(
          senderAddressData!['latitude'],
          senderAddressData!['longitude'],
        );

        var receiverAddressString = await getAddressFromLatLng(
          receiverAddressData!['latitude'],
          receiverAddressData!['longitude'],
        );

        var fullData = {
          "order_id": doc.id,
          "orderImg": data['order_image'],
          "senderName": senderData!['name'],
          "sender_address": senderAddressString,

          "receiverName": receiverData!['name'],
          "receiver_address": receiverAddressString,
        };

        tempList.add(fullData);
      }
      setState(() {
        orders = tempList;
        isLoading = false; // โหลดเสร็จแล้ว
      });
      log("Shipping => $orders");
    });
  }
  Future<String?> getAddressFromLatLng(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // เอาแค่ชื่อเมือง (locality)
        return place.locality; // เช่น "Kantharawichai"
      }
    } catch (e) {
      print("Error reverse geocoding: $e");
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDE10A),
        toolbarHeight: 120,
        automaticallyImplyLeading: false,

        title: Container(
          height: 40, //ค้นหา
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "หมายเลขโทรศัพท์หรือที่อยู่",
              border: InputBorder.none, //ลบขอบค้นหา
              contentPadding: EdgeInsets.symmetric(vertical: 10), //9exsoj'8hosk
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16), //ระยะห่างของปุ่มจากด้านบน
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey), //กรอบ
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ), //ปุ่ม
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateOrderPage(uid: widget.uid),
                    ),
                  );
                },
                icon: const Icon(Icons.local_shipping, color: Colors.yellow),
                label: const Text("ส่งสินค้า"),
              ),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Shipping(uid: widget.uid),
                    ),
                  );
                },
                icon: const Icon(Icons.inventory, color: Colors.yellow),
                label: const Text("ดูสินค้าที่กำลังส่ง"),
              ),
              

            ],
          ),
        ],
      ),
      
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFFDE10A),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Profileuser(uid: widget.uid),
              ),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  Shipping(uid: widget.uid)),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryUser(uid: widget.uid),
              ),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "หน้าหลัก"),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "ประวัติการส่ง",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: "ที่ต้องได้รับ",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "อื่น"),
        ],
      ),
    );
  }
}

/// ------------------ หน้า ส่งสินค้า ------------------

class CreateOrderPage extends StatefulWidget {
  String uid = '';
  CreateOrderPage({super.key, required this.uid});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  var db = FirebaseFirestore.instance;
  final nameController = TextEditingController();
  final qtyController = TextEditingController();
  final detailController = TextEditingController();
  final receiverController = TextEditingController();
  final addressController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  File? image;

  String? selectedAddress;
  List<Map<String, dynamic>> addresses = [];

  Map<String, dynamic>? userData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDE10A),
        title: const Text(
          "สร้างรายการส่งสินค้าใหม่",
          style: TextStyle(color: Colors.black),
        ), //textbar
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูป
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(12),
              ),
              child: (image != null)
                  ? Image.file(File(image!.path), fit: BoxFit.cover)
                  : Center(
                      child: GestureDetector(
                        onTap: addImg,
                        child: Icon(Icons.add, size: 40, color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
                onPressed: addImgByCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text("ถ่ายรูปสินค้า"),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "รายละเอียดสินค้า",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Details
            TextField(
              controller: detailController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "รายละเอียดสินค้า...",
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),

            // Receiver
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: receiverController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "ค้นหาผู้รับสินค้า",
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: queryData,
                  child: const Text("ค้นหา"),
                ),
              ],
            ),
            const SizedBox(height: 25),

            if (userData != null)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      color: Color.fromARGB(255, 239, 239, 239),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: userData?['profile_image'] == null
                                    ? Colors.grey
                                    : null, // สีพื้นหลังถ้าไม่มีรูป
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: userData?['profile_image'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        userData!['profile_image'],
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 40, top: 25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData?['name'],
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  userData?['phone'],
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
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
              ),
            const SizedBox(height: 25),

            // Address
            if (userData != null && addresses.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: DropdownMenu<String>(
                      width: double.infinity,
                      hintText: "เลือกที่อยู่ผู้รับ",
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      dropdownMenuEntries: addresses.map((addressData) {
                        String id = addressData['id'] ?? '';
                        String address = addressData['address'] ?? '';
                        return DropdownMenuEntry<String>(
                          value: id,
                          label: address,
                        );
                      }).toList(),
                      onSelected: (value) {
                        setState(() {
                          selectedAddress = value;
                          log(selectedAddress.toString());
                        });
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Submit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Center(
                child: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: addData,
                    child: const Text("ส่งสินค้า"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addImg() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    image = File(picked.path);
    setState(() {});
  }

  void addImgByCamera() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
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

  Future<void> queryData() async {
    //ค้นหาผู้ใช้
    var userRef = db.collection('users');
    var query = userRef.where("phone", isEqualTo: receiverController.text);
    var result = await query.get();

    if (result.docs.isNotEmpty) {
      var userDoc = result.docs.first;
      var user = userDoc.data();
      user['id'] = userDoc.id;
      log(user.toString());
      //  ถ้าพบผู้ใช้ → ดึงที่อยู่จาก collection addresses
      var addressRef = db.collection('address');
      log(userDoc.id);
      var addressQuery = addressRef.where("user_id", isEqualTo: userDoc.id);
      var addressResult = await addressQuery.get();

      addresses = addressResult.docs.map((doc) {
        var data = doc.data(); // ดึง Map<String, dynamic> ของแต่ละเอกสาร
        data['id'] = doc.id; // เพิ่ม field 'id' เป็น doc.id ของ Firestore
        return data; // คืน Map ที่มีทั้งข้อมูล + id
      }).toList();
      log(addresses.toString());

      // 3️⃣ อัปเดต state รวมผู้ใช้ + ที่อยู่
      setState(() {
        userData = {
          ...user, // ข้อมูลผู้ใช้
          'address': addresses, // ใส่ list ของที่อยู่
        };
      });
    } else {
      setState(() {
        userData = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("ไม่พบผู้ใช้ที่มีเบอร์นี้")));
    }
  }

  Future<void> addData() async {
    try {
      String senderId = widget.uid;
      var docOrder = db.collection('orders').doc();
      var addressRef = db.collection('address');
      var addressQuery = addressRef.where("user_id", isEqualTo: widget.uid);
      var resultAddress = await addressQuery.get();
      int status = 0;
      String? addressSender;
      if (resultAddress.docs.isNotEmpty) {
        var addressDoc = resultAddress.docs.first;
        addressSender = addressDoc.id;
        log(addressDoc.id);
      }

      log(widget.uid);

      String? imageUrl;

      // ถ้ามีภาพจาก addImg() → อัปโหลดก่อน
      if (image != null) {
        imageUrl = await uploadToCloudinary(image!);
        log("imageUrl : $imageUrl");
      } else {
        log("No image");
      }

      var data = {
        'sender_id': widget.uid,
        'sender_address_id': addressSender,
        'details': detailController.text,
        'receiver_id': userData?['id'],
        'receiver_address_id': selectedAddress,
        if (imageUrl != null) 'order_image': imageUrl,
        'status': status,
        'createdAt': DateTime.now(),
      };

      log(data.toString());
      await docOrder.set(data);
      log("${docOrder.id} สร้างสำเร็จ");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePageUser(uid: senderId)),
      );
    } catch (error) {
      log(error.toString());
    }
  }
}
