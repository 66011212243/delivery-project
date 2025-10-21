import 'package:delivery/page/AddressPage.dart';
import 'package:delivery/page/homepageRider.dart';
import 'package:delivery/page/mapAddress.dart';
import 'package:delivery/page/Receive.dart';
import 'package:delivery/page/homepageRider.dart';
import 'package:delivery/page/homepageUser.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/page/HistoryUser.dart';
import 'package:delivery/page/profileUser.dart';
import 'package:delivery/page/Product_details.dart';

class Profileuser extends StatefulWidget {
  final String uid; // ใช้ final
  Profileuser({super.key, required this.uid});
  @override
  State<Profileuser> createState() => _ProfileuserState();
}

class _ProfileuserState extends State<Profileuser> {
  int _currentIndex = 3;

  String? name;
  String? phone;
  String? profileUrl;
  String? address;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRiderData();
  }

  Future<void> fetchRiderData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      QuerySnapshot addressSnapshot = await FirebaseFirestore.instance
          .collection('address')
          .where('user_id', isEqualTo: widget.uid)
          .get();

      String? addr = addressSnapshot.docs.isNotEmpty
          ? (addressSnapshot.docs.first.data()
                as Map<String, dynamic>)['address']
          : 'ไม่พบที่อยู่';

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          name = data['name'] ?? 'ไม่พบชื่อ';
          phone = data['phone'] ?? '-';
          address = addr;
          profileUrl = data['profile_image'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          name = 'ไม่พบผู้ใช้';
          phone = '-';
          address = '-';
        });
      }
    } catch (e) {
      print('Error fetching rider data: $e');
      setState(() {
        isLoading = false;
        name = 'ข้อผิดพลาดในการโหลดข้อมูล';
        phone = '-';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        leading: const BackButton(color: Colors.black),
        title: const Text('โปรไฟล์'),
      ),

      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            ) // แสดง Loading ขณะดึงข้อมูล
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Center(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage:
                                      profileUrl != null &&
                                          profileUrl!.isNotEmpty
                                      ? NetworkImage(profileUrl!)
                                      : AssetImage('assets/images/pfboy.png')
                                            as ImageProvider,
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    bottom: 20,
                                  ),
                                  child: Text(
                                    name ?? 'ไม่พบชื่อ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- เบอร์มือถือ ---
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 30,
                                  bottom: 10,
                                  left: 20,
                                  right: 20,
                                ),
                                child: Text(
                                  "เบอร์มือถือ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                width: 340,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 241, 241, 241),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      phone ?? '-',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 30,
                                  bottom: 10,
                                  left: 20,
                                  right: 20,
                                ),
                                child: Text(
                                  "ที่อยู่",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                width: 340,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 241, 241, 241),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      address ?? '-',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddressPage(uid: widget.uid),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'เพิ่มที่อยู่',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),

                              // --- ส่วนที่อยู่ถูกลบออกไปแล้ว ---
                            ],
                          ),
                        ),
                      ],
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
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePageUser(uid: widget.uid),
              ),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Receive(uid: widget.uid)),
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

  void gotoHomepage() {
    // // แก้ไขให้ใช้ pushReplacement และส่ง uid ไปด้วย (ถ้า Homepagerider ต้องการ)
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => Homepagerider(uid: widget.uid)),
    // );
  }
}
