import 'dart:async';
import 'dart:developer';

import 'package:delivery/page/Product_details.dart';
import 'package:delivery/page/coordinatesSender.dart';
import 'package:delivery/page/senderStatus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class Shipping extends StatefulWidget {
  final String uid;
  const Shipping({super.key, required this.uid});

  @override
  State<Shipping> createState() => _ShippingState();
}

class _ShippingState extends State<Shipping> {
  var db = FirebaseFirestore.instance;
  StreamSubscription? listenerShipping;
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        leading: const BackButton(color: Colors.black),
        title: const Text('รายการสินค้าที่กำลังจัดส่ง'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Coordinatessender(uid: widget.uid),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("ดูพิกัดรวม"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 25),
                                    child: Image.asset(
                                      'assets/images/logo_delivery.jpg',
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              order['receiver_address'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Text(
                                            'ชื่อผู้รับ : ${order['receiverName']}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                       
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              order['sender_address'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Text(
                                            'ชื่อผู้ส่ง : ${order['senderName']}',
                                          ),
                                        ),
                                         
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Product_details(
                                                          uid: widget.uid,
                                                          orderId:
                                                              order['order_id'],
                                                        ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                foregroundColor: Colors.black,
                                              ),
                                              child: const Text("รายละเอียด"),
                                            ),
                                            const SizedBox(width: 13),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Senderstatus(
                                                          oid:
                                                              order['order_id'],
                                                        ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                foregroundColor: Colors.black,
                                              ),
                                              child: const Text("สถานะ"),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void getOrder() async {
    // setState(() {
    //   isLoading = true; // เริ่มโหลด
    // });
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
          "phoneUser":senderData!['phone'],

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
}
