import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Shipping extends StatefulWidget {
  final String uid;
  const Shipping({super.key, required this.uid});

  @override
  State<Shipping> createState() => _ShippingState();
}
class _ShippingState extends State<Shipping> {

String name = '';
String phone = '';
String profileUrl = '';
String address = '';
String riderUsers = '';
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    fetchRiderData();
  }

   List<Map<String, dynamic>> tempList = [];
   Future<void> fetchRiderData() async {
  try {
    // 1ดึงข้อมูลผู้ใช้จาก collection 'users'
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: widget.uid)
        .get();

    // 2️ดึงข้อมูลผู้ขับขี่จาก collection 'riders'
    QuerySnapshot ridersSnapshot = await FirebaseFirestore.instance
        .collection('riders')
        .where('user_id', isEqualTo: widget.uid)
        .get();

    // 3️ดึงข้อมูลที่อยู่จาก collection 'address'
    QuerySnapshot addressSnapshot = await FirebaseFirestore.instance
        .collection('address')
        .where('user_id', isEqualTo: widget.uid)
        .get();

    // แยกค่าที่ต้องการจาก ridersSnapshot
    String riderName = ridersSnapshot.docs.isNotEmpty
        ? (ridersSnapshot.docs.first.data() as Map<String, dynamic>)['users'] ?? 'ไม่พบผู้ใช้'
        : 'ไม่พบผู้ใช้';

    // แยกค่าที่อยู่
    String address = addressSnapshot.docs.isNotEmpty
        ? (addressSnapshot.docs.first.data() as Map<String, dynamic>)['address'] ?? 'ไม่พบที่อยู่'
        : 'ไม่พบที่อยู่';

    // ตรวจสอบว่ามีผู้ใช้หรือไม่
    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs.first.data() as Map<String, dynamic>;

      setState(() {
        name = userData['name'] ?? 'ไม่พบชื่อ';
        phone = userData['phone'] ?? '-';
        profileUrl = userData['profile_image'] ?? '';
        address = address;      
        riderUsers = riderName;  
        isLoading = false;
      });
    } else {
      setState(() {
        name = 'ไม่พบผู้ใช้';
        phone = '-';
        profileUrl = '';
        address = address;
        riderUsers = riderName;
        isLoading = false;
      });
    }
  } catch (e) {
    print('Error fetching rider data: $e');
    setState(() {
      isLoading = false;
      name = 'ข้อผิดพลาดในการโหลดข้อมูล';
      phone = '-';
      profileUrl = '';
      address = '-';
      riderUsers = '-';
    });
  }
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
        child: ListView.builder(
          itemCount: 4, // เปลี่ยนจำนวนรายการตามต้องการ
          itemBuilder: (context, index) {
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
                  Padding(
                    padding: const EdgeInsets.only(right: 25),
                 child: Image.asset('assets/images/logo_delivery.jpg', width: 60, height: 60),
                 ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_on, color: Colors.red, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'มหาวิทยาลัยมหาสารคาม',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text('ชื่อผู้รับ : Manlika'),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Icon(Icons.location_on, color: Colors.green, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Big-C Onnut',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text('ชื่อผู้ส่ง : Mullika'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text("รายละเอียด"),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {},
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
            );
          },
        ),
      ),
    );
  }
}
