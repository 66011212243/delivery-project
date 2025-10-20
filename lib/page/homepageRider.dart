import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/page/profileRider.dart';
import 'package:delivery/page/riderSendOrder.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Homepagerider extends StatefulWidget {
  String rid = '';
  Homepagerider({super.key, required this.rid});

  @override
  State<Homepagerider> createState() => _HomepageriderState();
}

class _HomepageriderState extends State<Homepagerider> {
  var db = FirebaseFirestore.instance;
  StreamSubscription? listener;
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    startRealtime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: Image.asset(
                  'assets/images/logo_delivery.jpg',
                  width: 58,
                ),
              ),
              Text("SnapSend", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        backgroundColor: Color.fromARGB(255, 253, 225, 10),
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
      ),

      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 253, 225, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // มุมโค้ง
                    ),
                  ),
                  child: Text(
                    "ประกาศจ้าง",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator()) // Loader ขณะโหลด
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 20,
                                        bottom: 25,
                                      ),
                                      child: Container(
                                        width: 320,
                                        height: 270,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            255,
                                            255,
                                            255,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(16),
                                          ),
                                          border: Border.all(
                                            color: Color.fromARGB(
                                              255,
                                              110,
                                              109,
                                              109,
                                            ),
                                          ),
                                        ),

                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            order['senderImage'] ==
                                                                    null ||
                                                                order['senderImage']
                                                                    .isEmpty
                                                            ? Colors.grey[400]
                                                            : null,
                                                        image:
                                                            order['senderImage'] !=
                                                                    null &&
                                                                order['senderImage']
                                                                    .isNotEmpty
                                                            ? DecorationImage(
                                                                image: NetworkImage(
                                                                  order['senderImage'],
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : null,
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  left: 20,
                                                                ),
                                                            child: Text(
                                                              order['senderName'],
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  left: 20,
                                                                ),
                                                            child: Text(
                                                              order['senderPhone'],
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 30,
                                                        ),
                                                    child: Container(
                                                      child: Image.asset(
                                                        'assets/images/box.png',
                                                        width: 40,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      order['sender_address'],
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 230,
                                                  bottom: 10,
                                                ),
                                                child: Container(
                                                  width:
                                                      2, // ความกว้างเต็ม parent
                                                  height: 30, // ความหนา
                                                  color: Colors.black,
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 10,
                                                  bottom: 15,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 30,
                                                          ),
                                                      child: Container(
                                                        child: Image.asset(
                                                          'assets/images/pin_images.png',
                                                          width: 30,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Text(
                                                        order['receiver_address'],
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Center(
                                                child: FilledButton(
                                                  onPressed: () async {
                                                    await acceptOrder(
                                                      order['order_id'],
                                                      widget.rid,
                                                    );
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Ridersendorder(
                                                              order_id:
                                                                  order['order_id'],
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  style: FilledButton.styleFrom(
                                                    backgroundColor:
                                                        Color.fromARGB(
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
                                                    "รับงาน",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            Container(
              width: 450,
              height: 80,
              color: Color.fromARGB(255, 255, 255, 255),
              child: Container(
                width: 350,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          label: Icon(
                            Icons.home,
                            size: 35,
                            color: Color.fromARGB(255, 255, 187, 2),
                          ),
                        ),
                        Text(
                          "หน้าหลัก",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 187, 2),
                          ),
                        ),
                      ],
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: gotoProfile,
                          label: Icon(
                            Icons.person,
                            size: 35,
                            color: Colors.black,
                          ),
                        ),

                        Text(
                          "ฉัน",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  void gotoProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Profilerider(rid: widget.rid)),
    );
  }

  void startRealtime() async {
    setState(() {
      isLoading = true; // เริ่มโหลด
    });
    final docOrder = db.collection("orders").where("status", isEqualTo: 1);
    var userDoc = db.collection('users');
    var addressDoc = db.collection('address');
    if (listener != null) {
      await listener!.cancel();
      listener = null;
    }

    listener = docOrder.snapshots().listen(
      (querySnapshot) async {
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
            "senderName": senderData!['name'],
            "senderPhone": senderData!['phone'],
            "senderImage": senderData!['profile_image'],
            "sender_address": senderAddressString,
            "receiver_address": receiverAddressString,
          };

          tempList.add(fullData);
        }
        setState(() {
          orders = tempList;
          isLoading = false; // โหลดเสร็จแล้ว
        });

        log("UPDATED ORDERS => $orders");
      },
      onError: (error) {
        log("Listen failed: $error");
      },
    );
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

  Future<void> acceptOrder(String orderId, String riderId) async {
    final docOrder = db.collection("orders").doc(orderId);
    try {
      Position myPosition = await _determinePosition();
      log('Lat: ${myPosition.latitude}, Lng: ${myPosition.longitude}');

      var riderDoc = db.collection('riders').doc(widget.rid);
      await riderDoc.update({
        'latitude': myPosition.latitude,
        'longitude': myPosition.longitude,
      });

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docOrder);
        if (!snapshot.exists) {
          throw Exception("งานนี้ไม่มีอยู่จริง");
        }
        final status = snapshot['status'] ?? 1;
        if (status == 2) {
          // งานถูกรับไปแล้ว
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("ไม่สามารถรับงานได้"),
              content: Text("งานนี้มีคนรับไปแล้ว"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("ตกลง"),
                ),
              ],
            ),
          );
        }
        transaction.update(docOrder, {'status': 2, 'rider_id': riderId});
      });
    } catch (err) {
      log("ไม่สามารถรับงานได้: $err");
    }
  }

  void getLocation() async {
    try {
      Position myPosition = await _determinePosition();
      log('Lat: ${myPosition.latitude}, Lng: ${myPosition.longitude}');

      var riderDoc = db.collection('riders').doc(widget.rid);
      await riderDoc.update({
        'latitude': myPosition.latitude,
        'longitude': myPosition.longitude,
      });
    } catch (e) {
      log('Error: $e');
    }
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
