import 'package:flutter/material.dart';

class Sender_details extends StatelessWidget {
  const Sender_details({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        leading: const BackButton(color: Colors.black),
        title: const Text('รายการสินค้าที่กำลังจัดส่ง'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.yellow,
                      radius: 50,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/khong2.png',
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    SizedBox(height: 8),
                    Text('ผู้ส่ง'),
                  ],
                ),
                Icon(Icons.arrow_forward, size: 32),
                Column(
                  children: [
                   CircleAvatar(
                      backgroundColor: Colors.yellow,
                      radius: 50,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/recipient.png',
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('ผู้รับ'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Container(
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
                children: [
                  Image.asset(
                    'assets/images/logo.png', 
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'รายละเอียด',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('samsung s25 ultra 512 | 12GB'),
                      Text('Titanium Jetblack'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}