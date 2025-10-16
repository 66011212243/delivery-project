
import 'package:delivery/page/profileRider.dart';
import 'package:flutter/material.dart';

class Homepagerider extends StatefulWidget {
  String rid = '';
  Homepagerider({super.key, required this.rid});

  @override
  State<Homepagerider> createState() => _HomepageriderState();
}

class _HomepageriderState extends State<Homepagerider> {
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
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // มุมโค้ง
                            ),
                          ),
                          child: Text(
                            "ประกาศจ้าง",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),

                    Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 25),
                            child: Container(
                              width: 320,
                              height: 270,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                                border: Border.all(
                                  color: Color.fromARGB(255, 110, 109, 109),
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
                                              color: const Color.fromARGB(
                                                255,
                                                180,
                                                179,
                                                179,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),

                                          Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 20,
                                                      ),
                                                  child: Text(
                                                    "พิชชาภรณ์ ยานรัมย์",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 20,
                                                      ),
                                                  child: Text(
                                                    "098777777",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                          padding: const EdgeInsets.only(
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
                                            "Big-C Onnut",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
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
                                        width: 2, // ความกว้างเต็ม parent
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
                                            padding: const EdgeInsets.only(
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
                                              "มหาวิทยาลัยมหาสารคาม",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Center(
                                      child: FilledButton(
                                        onPressed: () {},
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                            255,
                                            255,
                                            187,
                                            2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ), // มุมโค้ง
                                          ),
                                        ),
                                        child: Text(
                                          "รับงาน",
                                          style: TextStyle(color: Colors.black),
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
      MaterialPageRoute(builder: (context) => const Profilerider()),
    );
  }
}
