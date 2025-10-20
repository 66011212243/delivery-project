import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/page/homepageRider.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class Ridersendorder extends StatefulWidget {
  String order_id;
  Ridersendorder({super.key, required this.order_id});

  @override
  State<Ridersendorder> createState() => _RidersendorderState();
}

class _RidersendorderState extends State<Ridersendorder> {
  var db = FirebaseFirestore.instance;
  StreamSubscription? listener;
  StreamSubscription? listenerRider;
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  Map<String, dynamic>? orderData;
  Map<String, dynamic>? getLatLng;
  Map<String, dynamic>? getLatLngRider;

  final ImagePicker picker = ImagePicker();
  File? image;

  XFile? selectedImage;
  String? imageUrl;

  File? imageStatus4;
  String? imageUrlStatus4;

  @override
  void initState() {
    super.initState();
    startRealtime();
    // updateLatLng();
  }

  int activeStep = 0;

  var mapController = MapController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.order_id)),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: LatLng(16.246373, 103.251827),
                  initialZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=1ef19f91909b4ac1ad3dfb1dc523a2c6',
                    userAgentPackageName: 'com.example.delivery',
                  ),

                  MarkerLayer(
                    markers: [
                      if (orderData != null &&
                          orderData!['status'] == 2 &&
                          getLatLng?['latitudeSender'] != null &&
                          getLatLng?['longitudeSender'] != null)
                        Marker(
                          point: LatLng(
                            getLatLng!['latitudeSender']!,
                            getLatLng!['longitudeSender']!,
                          ),
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      if (orderData != null &&
                          orderData!['status'] == 3 &&
                          getLatLng?['latitudeReceiver'] != null &&
                          getLatLng?['longitudeReceiver'] != null)
                        Marker(
                          point: LatLng(
                            getLatLng!['latitudeReceiver']!,
                            getLatLng!['longitudeReceiver']!,
                          ),
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),

                      if (orderData != null &&
                          getLatLngRider?['latitudeRider'] != null &&
                          getLatLngRider?['longitudeRider'] != null)
                        Marker(
                          point: LatLng(
                            getLatLngRider!['latitudeRider']!,
                            getLatLngRider!['longitudeRider']!,
                          ),
                          width: 40,
                          height: 40,
                          child: Image.asset('assets/images/bike.png'),
                        ),
                    ],
                  ),

                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),

                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 254, 251),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), // สีเงา
                              spreadRadius: 2, // ความกว้างเงา
                              blurRadius: 6, // ความฟุ้งของเงา
                              offset: Offset(0, 3), // แนวเงา (x, y)
                            ),
                          ],
                        ),
                        child: EasyStepper(
                          activeStep: activeStep,
                          lineStyle: LineStyle(
                            lineType: LineType.normal,
                            lineThickness: 2,
                            activeLineColor: Colors.yellow[700],
                            finishedLineColor: Colors.yellow[700],
                            unreachedLineColor: Colors.grey[300],
                          ),
                          activeStepTextColor: Colors.black,
                          finishedStepTextColor: Colors.grey[300],
                          internalPadding: 8,
                          showLoadingAnimation: false,
                          stepRadius: 25,
                          showStepBorder: false,
                          steps: [
                            EasyStep(
                              icon: Icon(
                                Icons.delivery_dining_outlined,
                                size: 50,
                              ),
                              title: 'ไรเดอร์รับงาน',
                            ),
                            EasyStep(
                              icon: Icon(
                                Icons.local_shipping_outlined,
                                size: 50,
                              ),
                              title: 'กำลังเดินทาง',
                            ),
                            EasyStep(
                              icon: Icon(Icons.home_outlined, size: 50),
                              title: 'ส่งสินค้าสำเร็จ',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Container(
                  //   alignment: Alignment.center,
                  //   margin: EdgeInsets.only(bottom: 150),
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.end,

                  //     children: [
                  //       const SizedBox(height: 10),
                  //       ElevatedButton.icon(
                  //         onPressed: getLocation,

                  //         icon: const Icon(Icons.person_outline),
                  //         label: const Text('ดู'),
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: Colors.yellow[700],
                  //           foregroundColor: Colors.black,
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,

                      children: [
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: (orderData == null)
                              ? null
                              : _showDriverInfo,

                          icon: const Icon(Icons.person_outline),
                          label: const Text('ดูข้อมูล'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[700],
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDriverInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ให้ popup สูงได้มาก
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "ผู้ส่ง",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 89, 89, 89),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ClipOval(
                          child: orderData?['senderImage'] != null
                              ? Image.network(
                                  orderData!['senderImage'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey, // สีเทา
                                ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(orderData?['senderName']),
                            Text(orderData?['senderPhone']),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/box.png',
                          width: 50,
                          height: 50,
                        ),

                        const SizedBox(width: 10),
                        Text(
                          orderData?['sender_address'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 90),
                  child: Container(
                    width: 70,
                    height: 2,
                    color: Colors.black, // สีเส้น
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "ผู้รับ",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 89, 89, 89),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(orderData?['receiverName']),
                            Text(orderData?['receiverPhone']),
                          ],
                        ),
                        const SizedBox(width: 10),
                        ClipOval(
                          child: orderData?['receiverImage'] != null
                              ? Image.network(
                                  orderData!['receiverImage'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey, // สีเทาเป็น placeholder
                                ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 100),
                          child: Text(
                            orderData?['receiver_address'] ?? "",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                          ),
                        ),

                        const SizedBox(width: 15),
                        Image.asset(
                          'assets/images/pin_images.png',
                          width: 25,
                          height: 25,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
            if (orderData!['status'] == 2)
              Column(
                children: [
                  Container(
                    width: 250,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 241, 241, 241),
                    ),
                    child: Container(
                      child: (image != null)
                          ? Image.file(File(image!.path), fit: BoxFit.cover)
                          : Center(
                              child: GestureDetector(
                                onTap: () => addImgByCamera(3),
                                child: Icon(
                                  Icons.camera_alt, // ไอคอนกล้อง
                                  size: 30, // ขนาดไอคอน
                                  color:
                                      Colors.black, // สีไอคอน (ปรับตามต้องการ)
                                ),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 10),

                  Center(
                    child: FilledButton(
                      onPressed: updateStatus3,
                      style: FilledButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 187, 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // มุมโค้ง
                        ),
                      ),
                      child: Text(
                        "อัปเดต",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            if (orderData!['status'] == 3)
              Column(
                children: [
                  Container(
                    width: 250,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 241, 241, 241),
                    ),
                    child: Container(
                      child: (imageStatus4 != null)
                          ? Image.file(
                              File(imageStatus4!.path),
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: GestureDetector(
                                onTap: () => addImgByCamera(4),
                                child: Icon(
                                  Icons.camera_alt, // ไอคอนกล้อง
                                  size: 30, // ขนาดไอคอน
                                  color:
                                      Colors.black, // สีไอคอน (ปรับตามต้องการ)
                                ),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 10),

                  Center(
                    child: FilledButton(
                      onPressed: updateStatus4,
                      style: FilledButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 187, 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // มุมโค้ง
                        ),
                      ),
                      child: Text(
                        "อัปเดต",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (orderData!['status'] == 4)
              Center(
                child: FilledButton(
                  onPressed: () {
                    log(orderData!['rider_id']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Homepagerider(rid: orderData?['rider_id']),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 187, 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // มุมโค้ง
                    ),
                  ),
                  child: Text(
                    "ยืนยันการจบงาน",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void startRealtime() async {
    setState(() {
      isLoading = true; // เริ่มโหลด
    });
    final docOrder = db.collection("orders").doc(widget.order_id);
    var userDoc = db.collection('users');
    var addressDoc = db.collection('address');
    if (listener != null) {
      await listener!.cancel();
      listener = null;
    }
    listener = docOrder.snapshots().listen((event) async {
      var data = event.data();
      var status = data?['status'];
      var riderId = data?['rider_id'];
      var senderId = data?['sender_id'];
      var receiverId = data?['receiver_id'];
      var senderAddress = data?['sender_address_id'];
      var receiverAddress = data?['receiver_address_id'];

      log("data : ${event.data()}");

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

      setState(() {
        orderData = {
          "status": status,
          "rider_id": riderId,
          "senderName": senderData!['name'],
          "senderPhone": senderData!['phone'],
          "senderImage": senderData!['profile_image'],
          "sender_address": senderAddressString,

          "receiverName": receiverData!['name'],
          "receiverPhone": receiverData!['phone'],
          "receiverImage": receiverData!['profile_image'],
          "receiver_address": receiverAddressString,
        };
        getLatLng = {
          "latitudeSender": senderAddressData!['latitude'],
          "longitudeSender": senderAddressData!['longitude'],
          "latitudeReceiver": receiverAddressData!['latitude'],
          "longitudeReceiver": receiverAddressData!['longitude'],
        };

        activeStep = mapStatusToStep(orderData!['status']);
        if (orderData?['rider_id'] != null) {
          getLocation();
        }
        isLoading = false;
      });

      log("orderData: ${orderData.toString()}");
    }, onError: (error) => log("Listen failed: $error"));
  }

  void getLocation() async {
    var riderDoc = db.collection('riders').doc(orderData!['rider_id']);
    if (listenerRider != null) {
      await listenerRider!.cancel();
      listenerRider = null;
    }
    listenerRider = riderDoc.snapshots().listen((event) {
      var data = event.data();
      var latitude = data?['latitude'];
      var longitude = data?['longitude'];
      setState(() {
        getLatLngRider = {
          'latitudeRider': latitude,
          'longitudeRider': longitude,
        };
      });
      log(getLatLngRider.toString());
      log("current data: ${event.data()}");
    }, onError: (error) => log("Listen failed: $error"));
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

  int mapStatusToStep(int status) {
    switch (status) {
      case 2:
        return 0; // ไรเดอร์รับงาน
      case 3:
        return 1; // กำลังเดินทาง
      case 4:
        return 2; // ส่งสินค้าสำเร็จ
      default:
        return 0; // ค่า default
    }
  }

  void addImgByCamera(int statusimg) async {
    int status = statusimg;
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    setState(() {
      if (status == 3) {
        image = File(picked.path);
      }
      if (status == 4) {
        imageStatus4 = File(picked.path);
      }
    });
  }

  void updateStatus3() async {
    try {
      int status = 3;
      var orderDoc = db.collection('orders').doc(widget.order_id);

      // ถ้ามีภาพจาก addImg() → อัปโหลดก่อน
      if (image != null) {
        imageUrl = await uploadToCloudinary(image!);
        log("imageUrl : $imageUrl");
        await orderDoc.update({'status': status, 'image_status3': imageUrl});
      } else {
        log("No image");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('แจ้งเตือน'),
            content: Text('กรุณาอัปโหลดรูปภาพเพื่ออัปเดตสถานะสินค้า'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ปิด'),
              ),
            ],
          ),
        );
      }
    } catch (err) {
      log(err.toString());
    }
  }

  void updateStatus4() async {
    try {
      int status = 4;
      var orderDoc = db.collection('orders').doc(widget.order_id);

      // ถ้ามีภาพจาก addImg() → อัปโหลดก่อน
      if (imageStatus4 != null) {
        imageUrlStatus4 = await uploadToCloudinary(imageStatus4!);
        log("imageUrl : $imageUrlStatus4");
        await orderDoc.update({
          'status': status,
          'image_status4': imageUrlStatus4,
        });
      } else {
        log("No image");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('แจ้งเตือน'),
            content: Text('กรุณาอัปโหลดรูปภาพเพื่ออัปเดตสถานะสินค้า'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ปิด'),
              ),
            ],
          ),
        );
      }
    } catch (err) {
      log(err.toString());
    }
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

  void updateLatLng() {
    Timer.periodic(Duration(seconds: 7), (timer) async {
      Position position = await _determinePosition();
      await db.collection('riders').doc(orderData!['rider_id']).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
      log('Lat: ${position.latitude}, Lng: ${position.longitude}');
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }
}
