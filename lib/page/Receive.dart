import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/page/HistoryUser.dart';
import 'package:delivery/page/coordinatesReceive.dart';
import 'package:delivery/page/homepageUser.dart';
import 'package:delivery/page/profileUser.dart';
import 'package:delivery/page/receiverStatus.dart';
import 'package:flutter/material.dart';

class Receive extends StatefulWidget {
  String uid;
  Receive({super.key, required this.uid});

  @override
  State<Receive> createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  int _currentIndex = 2;
  var db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    getOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDE10A),
        title: const Text(
          "ที่ต้องได้รับ",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Align(
              alignment: Alignment.centerRight, // ชิดขวา
              child: ElevatedButton(
                onPressed: () {
                  log("receive " + widget.uid);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Coordinates(uid: widget.uid),
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
            child: (orders == null || orders.isEmpty)
                ? const Center(
                    child: Text(
                      'ไม่มีข้อมูล',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
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
                                color: Colors.grey,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100, // หรือ 80
                                height: 100,
                                child: order['order_image'] != null
                                    ? Image.network(
                                        order['order_image'],
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/box.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),

                              const SizedBox(width: 12),

                              // ข้อมูลสินค้า + ปุ่ม
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'รายละเอียด',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(order['details']),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Receiverstatus(
                                                    oid: order['order_id'],
                                                  ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                        child: const Text("ดูพิกัดไรเดอร์"),
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
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryUser(uid: widget.uid),
              ),
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

  void getOrder() async {
    try {
      var orderQuery = db
          .collection('orders')
          .where("receiver_id", isEqualTo: widget.uid);

      var orderData = await orderQuery.where("status", isLessThan: 4).get();

      var resultOrder = orderData.docs.map((doc) {
        final data = doc.data();
        data['order_id'] = doc.id;
        return data;
      }).toList();
      log(resultOrder.toString());

      setState(() {
        orders = resultOrder;
      });
    } catch (err) {
      log("error: $err");
    }
  }
}
