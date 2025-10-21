import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class Senderstatus extends StatefulWidget {
  String oid;
  Senderstatus({super.key, required this.oid});

  @override
  State<Senderstatus> createState() => _SenderstatusState();
}

class _SenderstatusState extends State<Senderstatus> {
  var mapController = MapController();
  var db = FirebaseFirestore.instance;
  StreamSubscription? listener;
  StreamSubscription? listenerRider;
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  Map<String, dynamic>? orderData;
  Map<String, dynamic>? dataRider;

  Map<String, dynamic>? getLatLng;
  Map<String, dynamic>? getLatLngRider;

  final ImagePicker picker = ImagePicker();
  File? image;

  XFile? selectedImage;
  String? imageUrl;
  int activeStep = 0;

  @override
  void initState() {
    super.initState();
    log("🔥 initState called");
    getGps();
  }

  @override
  void dispose() {
    stopRealtime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.oid)),
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
                          orderData?['latitudeSender'] != null &&
                          orderData?['longitudeSender'] != null)
                        Marker(
                          point: LatLng(
                            orderData!['latitudeSender']!,
                            orderData!['longitudeSender']!,
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
                          orderData?['latitudeReceiver'] != null &&
                          orderData?['longitudeReceiver'] != null)
                        Marker(
                          point: LatLng(
                            orderData!['latitudeReceiver']!,
                            orderData!['longitudeReceiver']!,
                          ),
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),

                      if (dataRider != null &&
                          dataRider?['latitudeRider'] != null &&
                          dataRider?['longitudeRider'] != null)
                        Marker(
                          point: LatLng(
                            dataRider!['latitudeRider']!,
                            dataRider!['longitudeRider']!,
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
                          horizontal: 10,
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
                          internalPadding: 5,
                          showLoadingAnimation: false,
                          stepRadius: 25,
                          showStepBorder: false,
                          steps: [
                            EasyStep(
                              icon: Icon(Icons.inventory_2_outlined, size: 50),
                              title: 'รอไรเดอร์',
                            ),
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
      builder: (context) => Container(
        width: MediaQuery.of(context).size.width, // 👈 เต็มความกว้างจอ

        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (orderData!['status'] != 0 && orderData!['status'] != 1)
              Row(
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "ข้อมูลไรเดอร์",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 255, 187, 2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            ClipOval(
                              child: dataRider?['profile'] != null
                                  ? Image.network(
                                      dataRider?['profile'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                            ),

                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dataRider?['riderName'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    dataRider?['riderPhone'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    dataRider?['vehicle_number'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              child: Column(
                children: [
                  Container(
                    width: 300,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 241, 241, 241),
                    ),
                    child: Container(
                      child: (image != null)
                          ? Image.file(File(image!.path), fit: BoxFit.cover)
                          : Center(
                              child: GestureDetector(
                                onTap: addImgByCamera,
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
                  if (orderData!['status'] == 0)
                    Center(
                      child: FilledButton(
                        onPressed: updateStatus1,
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

                  if (orderData!['status'] == 4)
                    Container(
                      width: 300,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 241, 241, 241),
                      ),
                      child: Container(
                        child: (orderData!['imgStatus4'] != null)
                            ? Image.network(
                                orderData!['imgStatus4'],
                                fit: BoxFit.cover,
                              )
                            : Center(child: GestureDetector(onTap: () {})),
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

  void getGps() async {
    final docOrder = db.collection("orders").doc(widget.oid);
    var riderDoc = db.collection('riders');
    var addressDoc = db.collection('address');
    var riderData;
    if (listener != null) {
      await listener!.cancel();
      listener = null;
    }

    listener = docOrder.snapshots().listen((event) async {
      var data = event.data();
      var status = data?['status'];
      var imgStatus4 = data?['image_status4'];
      var receiverAddress = data?['receiver_address_id'];
      var senderAddress = data?['sender_address_id'];

      var addressReceiver = await addressDoc.doc(receiverAddress).get();
      var addressSender = await addressDoc.doc(senderAddress).get();

      var receiverAddressData = addressReceiver.data();
      var senderAddressData = addressSender.data();

      // log("🔥 status = $status");
      // if (status == 4) {
      // log("🔥 status = $status");
      // log("🔥 image_status4 = ${data?['image_status4']}");

      setState(() {
        orderData = {
          "status": status,

          "latitudeReceiver": receiverAddressData!['latitude'],
          "longitudeReceiver": receiverAddressData!['longitude'],
          "latitudeSender": senderAddressData!['latitude'],
          "longitudeSender": senderAddressData!['longitude'],
          if (imgStatus4 != null) "imgStatus4": imgStatus4,
        };
        activeStep = mapStatusToStep(orderData!['status']);
        log("orderData: $orderData");
      });

      if (status != 0 && status != 1) {
        if (listenerRider != null) {
          await listenerRider!.cancel();
          listenerRider = null;
        }
        listenerRider = docOrder.snapshots().listen((event) async {
          var data = event.data();
          var riderId = data?['rider_id'];

          if (riderId != null) {
            var riderGet = await riderDoc.doc(riderId).get();
            riderData = riderGet.data() ?? {};
          }

          setState(() {
            dataRider = {
              "riderName": riderData['name'] ?? '',
              "riderPhone": riderData['phone'] ?? '',
              "vehicle_number": riderData['vehicle_number'] ?? '',
              "profile": riderData['profile_image'],
              "latitudeRider": riderData['latitude'],
              "longitudeRider": riderData['longitude'],
            };
            log("dataRider : $dataRider");
          });
        });
      }
    });
  }

  int mapStatusToStep(int status) {
    switch (status) {
      case 1:
        return 0;
      case 2:
        return 1; // ไรเดอร์รับงาน
      case 3:
        return 2; // กำลังเดินทาง
      case 4:
        return 3; // ส่งสินค้าสำเร็จ
      default:
        return 0; // ค่า default
    }
  }

  void addImgByCamera() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    image = File(picked.path);
    setState(() {});
  }

  void updateStatus1() async {
    try {
      int status = 1;
      var orderDoc = db.collection('orders').doc(widget.oid);

      // ถ้ามีภาพจาก addImg() → อัปโหลดก่อน
      if (image != null) {
        imageUrl = await uploadToCloudinary(image!);
        log("imageUrl : $imageUrl");
        await orderDoc.update({'status': status, 'image_status1': imageUrl});
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

  void stopRealtime() async {
    try {
      if (listener != null) {
        await listener!.cancel();
        listener = null;
      }
      if (listenerRider != null) {
        await listenerRider!.cancel();
        listener = null;
      }
    } catch (e) {
      log('Listener is not running...');
    }
  }
}
