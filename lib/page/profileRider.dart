import 'package:delivery/page/homepageRider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profilerider extends StatefulWidget {
  String rid = '';
  Profilerider({super.key, required this.rid});

  @override
  State<Profilerider> createState() => _ProfileriderState();
}

class _ProfileriderState extends State<Profilerider> {
  String? name;
  String? phone;
  String? profileUrl;
  String? vehicle_image;
  String? vehicle_number;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRiderData();
  }

  Future<void> fetchRiderData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('riders')
          .doc(widget.rid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          name = data['name'] ?? 'ไม่พบชื่อ';
          phone = data['phone'] ?? '-';
          profileUrl = data['profile_image'];
          vehicle_number = data['vehicle_number'] ?? 'ไม่พบรูปภาพ';
          vehicle_image = data['vehicle_image'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          name = 'ไม่พบผู้ใช้';
          phone = '-';
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
        title: Align(alignment: Alignment.bottomCenter, child: Text("โปรไฟล์")),
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 253, 225, 10),
        toolbarHeight: 90,
        centerTitle: true,
      ),

      body: Column(
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
                                profileUrl != null && profileUrl!.isNotEmpty
                                ? NetworkImage(profileUrl!)
                                : AssetImage('assets/images/pfboy.png')
                                      as ImageProvider,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 20),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 10),
                          child: Text(
                            "เบอร์โทรศัพท์",
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
                          padding: const EdgeInsets.only(top: 30, bottom: 10),
                          child: Text(
                            "ทะเบียนรถ",
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
                                vehicle_number ?? 'ไม่พบเลขทะเบียน',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 10),
                          child: Text(
                            "รูปยานพาหนะ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 150, // ขยายขนาด
                          height: 150, // ขยายขนาด
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 241, 241, 241),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior:
                              Clip.hardEdge, // ตัดขอบโค้งให้ Container
                          child: Image(
                            image:
                                vehicle_image != null &&
                                    vehicle_image!.isNotEmpty
                                ? NetworkImage(vehicle_image!)
                                : AssetImage('assets/images/pfboy.png'),
                            width: double.infinity, // ให้เต็ม Container
                            height: double.infinity, // ให้เต็ม Container
                            fit: BoxFit.cover, // ครอบเต็มพื้นที่
                            alignment: Alignment.center, // อยู่ตรงกลาง
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                        onPressed: gotoHomepage,
                        label: Icon(
                          Icons.home,
                          size: 35,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      Text(
                        "หน้าหลัก",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        label: Icon(
                          Icons.person,
                          size: 35,
                          color: Color.fromARGB(255, 255, 187, 2),
                        ),
                      ),

                      Text(
                        "ฉัน",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 187, 2),
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
    );
  }

  void gotoHomepage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Homepagerider(rid: widget.rid)),
    );
  }
}
