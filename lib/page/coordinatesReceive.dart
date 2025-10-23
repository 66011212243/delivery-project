import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Coordinates extends StatefulWidget {
  String uid;
  Coordinates({super.key, required this.uid});

  @override
  State<Coordinates> createState() => _CoordinatesState();
}

class _CoordinatesState extends State<Coordinates> {
  final mapController = MapController();
  var db = FirebaseFirestore.instance;
  StreamSubscription? listener;
  List<Map<String, dynamic>> orders = [];
  List<StreamSubscription> riderListeners = [];

  @override
  void initState() {
    super.initState();
    getGps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("พิกัดรวม"),
        backgroundColor: const Color.fromARGB(255, 253, 225, 10),
        toolbarHeight: 90,
        centerTitle: true,
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: const LatLng(16.246373, 103.251827),
          initialZoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=1ef19f91909b4ac1ad3dfb1dc523a2c6',
            userAgentPackageName: 'com.example.delivery',
          ),
          MarkerLayer(
            key: ValueKey(orders.length),
            markers: [
              for (var order in orders) ...[
                // จุดผู้ส่ง
                if (order['latitudeSender'] != null &&
                    order['longitudeSender'] != null)
                  Marker(
                    point: LatLng(
                      order['latitudeSender'],
                      order['longitudeSender'],
                    ),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                // จุดผู้รับ
                if (order['latitudeReceiver'] != null &&
                    order['longitudeReceiver'] != null)
                  Marker(
                    point: LatLng(
                      order['latitudeReceiver'],
                      order['longitudeReceiver'],
                    ),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                // จุดไรเดอร์ (ถ้ามี)
                if (order['latitudeRider'] != null &&
                    order['longitudeRider'] != null)
                  Marker(
                    point: LatLng(
                      order['latitudeRider'],
                      order['longitudeRider'],
                    ),
                    width: 40,
                    height: 40,
                    child: Image.asset('assets/images/bike.png'),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void getGps() async {
    try {
      var orderDoc = db
          .collection('orders')
          .where("receiver_id", isEqualTo: widget.uid)
          .where("status", isLessThan: 4);

      var riderDoc = db.collection("riders");
      var addressDoc = db.collection('address');

      // ยกเลิก listener เก่า order
      if (listener != null) {
        await listener!.cancel();
        listener = null;
      }

      listener = orderDoc.snapshots().listen((querySnapshot) async {
        List<Map<String, dynamic>> tempList = [];

        for (var sub in riderListeners) {
          await sub.cancel();
        }
        riderListeners.clear();

        for (var doc in querySnapshot.docs) {
          var data = doc.data();
          var senderAddress = data['sender_address_id'];
          var receiverAddress = data['receiver_address_id'];
          var riderId = data['rider_id'];

          var addressSender = await addressDoc.doc(senderAddress).get();
          var addressReceiver = await addressDoc.doc(receiverAddress).get();

          var senderAddressData = addressSender.data();
          var receiverAddressData = addressReceiver.data();

          var riderData;
          if (riderId != null) {
            var riderLatLng = await riderDoc.doc(riderId).get();
            riderData = riderLatLng.data();

            // สร้าง listener แยกสำหรับ rider ของ order นี้
            var sub = riderDoc.doc(riderId).snapshots().listen((event) {
              var data = event.data();
              if (data != null) {
                setState(() {
                  for (var o in orders) {
                    if (o['order_id'] == doc.id) {
                      o['latitudeRider'] = data['latitude'];
                      o['longitudeRider'] = data['longitude'];
                    }
                  }
                });
              }
            });

            riderListeners.add(sub);
          }

          var fullData = {
            "order_id": doc.id,
            "latitudeReceiver": receiverAddressData!['latitude'],
            "longitudeReceiver": receiverAddressData!['longitude'],
            "latitudeSender": senderAddressData!['latitude'],
            "longitudeSender": senderAddressData!['longitude'],
            if (riderId != null) "latitudeRider": riderData?['latitude'],
            if (riderId != null) "longitudeRider": riderData?['longitude'],
          };

          tempList.add(fullData);
        }

        setState(() {
          orders = tempList;
        });

        log("coordinates : $orders");
      });
    } catch (err) {
      log("error : $err");
    }
  }
}
