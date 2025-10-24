import 'dart:math' hide log;
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/page/Product_details.dart';
import 'package:delivery/page/Receive.dart';
import 'package:delivery/page/homepageUser.dart';
import 'package:delivery/page/profileUser.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class HistoryUser extends StatefulWidget {
  final String uid;
  const HistoryUser({super.key, required this.uid});

  @override
  _HistoryUserState createState() => _HistoryUserState();
}

class _HistoryUserState extends State<HistoryUser> {
  int _currentIndex = 1;

  String name = '';
  String phone = '';
  String profileUrl = '';
  String address = '';
  String riderUsers = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrdersOnce(); // ดึง orders พร้อมชื่อผู้ส่ง-ผู้รับ
  }

  List<Map<String, dynamic>> orders = [];

  Future<void> fetchOrdersOnce() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1️ ดึง orders ทั้งหมดที่จบงาน
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where("status", isEqualTo: 4)
          .get();

      // 2 กรองเฉพาะ order ที่ user คนนี้เกี่ยวข้อง (เป็นผู้ส่งหรือผู้รับ)
      final filteredOrders = ordersSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['sender_id'] == widget.uid ||
            data['receiver_id'] == widget.uid;
      }).toList();

      // 3️ดึง users, address, riders
      final usersSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .get();
      final addressSnapshot = await FirebaseFirestore.instance
          .collection("address")
          .get();
      final ridersSnapshot = await FirebaseFirestore.instance
          .collection("riders")
          .get();

      // 4 สร้าง map ไว้เรียกใช้
      Map<String, Map<String, dynamic>> userMap = {
        for (var doc in usersSnapshot.docs)
          doc.id: doc.data() as Map<String, dynamic>,
      };

      Map<String, Map<String, dynamic>> addressMap = {
        for (var doc in addressSnapshot.docs)
          doc.id: doc.data() as Map<String, dynamic>,
      };

      Map<String, Map<String, dynamic>> riderMap = {
        for (var doc in ridersSnapshot.docs)
          doc.id: doc.data() as Map<String, dynamic>,
      };

      // 5️รวมข้อมูล order ที่ผ่านการกรองแล้ว
      List<Map<String, dynamic>> tempOrders = [];

      for (var doc in filteredOrders) {
        final data = doc.data() as Map<String, dynamic>;

        // ดึงข้อมูลผู้ส่ง/ผู้รับ
        var senderData = userMap[data['sender_id']];
        var receiverData = userMap[data['receiver_id']];

        // ดึง address (เช็ก null ป้องกัน error)
        var senderAddressData = addressMap[data['sender_address_id']];
        var receiverAddressData = addressMap[data['receiver_address_id']];

        var senderAddressString = senderAddressData != null
            ? await getAddressFromLatLng(
                senderAddressData['latitude'],
                senderAddressData['longitude'],
              )
            : "-";

        var receiverAddressString = receiverAddressData != null
            ? await getAddressFromLatLng(
                receiverAddressData['latitude'],
                receiverAddressData['longitude'],
              )
            : "-";

        // ดึง rider (ถ้ามี)
        Map<String, dynamic>? riderData;
        if (data['rider_id'] != null) {
          riderData = riderMap[data['rider_id']];
        }

        // รวมข้อมูลทั้งหมด
        var fullOrder = {
          "order_id": doc.id,
          "senderName": senderData?['name'] ?? '-',
          "senderPhone": senderData?['phone'] ?? '-',
          "senderImage": senderData?['profile_image'] ?? '',
          "senderAddress": senderAddressString,
          "receiverName": receiverData?['name'] ?? '-',
          "receiverAddress": receiverAddressString,
          "riderName": riderData?['name'] ?? '-',
          "riderPhone": riderData?['phone'] ?? '-',
        };

        tempOrders.add(fullOrder);
      }

      // 6️อัปเดต state
      setState(() {
        orders = tempOrders;
        isLoading = false;
      });

      log("Fetched Orders => $orders");
    } catch (e) {
      print("Error fetching orders: $e");
      setState(() {
        isLoading = false;
      });
    }
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDE10A),
        automaticallyImplyLeading: false,
        title: const Text(
          "ประวัติการส่งสินค้า",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: orders.length, // ใช้จำนวนรายการจริง
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/logo_delivery_login.jpg',
                          width: 60,
                          height: 60,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    order['receiverAddress'] ?? '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  'ชื่อผู้รับ : ${order['receiverName'] ?? '-'}',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    order['senderAddress'] ?? '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  'ชื่อผู้ส่ง : ${order['senderName'] ?? '-'}',
                                ),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Product_details(
                                          uid: widget.uid,
                                          orderId: order['order_id'],
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
              MaterialPageRoute(builder: (context) => Receive(uid: widget.uid)),
            );
          }
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePageUser(uid: widget.uid),
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
