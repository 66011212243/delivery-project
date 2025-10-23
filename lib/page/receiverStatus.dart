import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class Receiverstatus extends StatefulWidget {
  String oid;
  Receiverstatus({super.key, required this.oid});

  @override
  State<Receiverstatus> createState() => _ReceiverstatusState();
}

class _ReceiverstatusState extends State<Receiverstatus> {
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
  int activeStep = 0;

  @override
  void initState() {
    super.initState();
    getGps();
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
                            color: Colors.blue,
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
                          onPressed:
                              (orderData == null ||
                                  orderData!['status'] == 1 ||
                                  orderData!['status'] == 0)
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
                                  "ชื่อ :${dataRider?['riderName']}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "เบอร์โทรศัพท์ :${dataRider?['riderPhone']}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "ทะเบียนรถ : ${dataRider?['vehicle_number']}",
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
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
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
    if (listener != null) {
      await listener!.cancel();
      listener = null;
    }

    listener = docOrder.snapshots().listen((event) async {
      var data = event.data();
      var status = data?['status'];
      var receiverAddress = data?['receiver_address_id'];
      var senderAddress = data?['sender_address_id'];

      var addressReceiver = await addressDoc.doc(receiverAddress).get();
      var addressSender = await addressDoc.doc(senderAddress).get();

      var receiverAddressData = addressReceiver.data();
      var senderAddressData = addressSender.data();

      setState(() {
        orderData = {
          "rider_id": data?['rider_id'],
          "status": status,
          "latitudeReceiver": receiverAddressData!['latitude'],
          "longitudeReceiver": receiverAddressData!['longitude'],
          "latitudeSender": senderAddressData!['latitude'],
          "longitudeSender": senderAddressData!['longitude'],
        };
        activeStep = mapStatusToStep(orderData!['status']);
        log("orderData: $orderData");
      });

      if (status != 0 && status != 1) {

        getLocation();
      }
    });
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
      var riderName = data?['name'];
      var riderPhone = data?['phone'];
      var vehicle_number = data?['vehicle_number'];
      var profile = data?['profile_image'];

      setState(() {
        dataRider = {
          'latitudeRider': latitude,
          'longitudeRider': longitude,
          "riderName": riderName,
          "riderPhone": riderPhone,
          "vehicle_number": vehicle_number,
          "profile": profile,
        };
      });
      log(dataRider.toString());
      log("current data: ${event.data()}");
    }, onError: (error) => log("Listen failed: $error"));
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
