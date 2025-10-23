import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class Product_details extends StatefulWidget {
  final String uid;
  final String orderId; // รับ orderId

  const Product_details({
    super.key,
    required this.uid,
    required this.orderId,
  });

  @override
  State<Product_details> createState() => _Product_detailsState();
}

class _Product_detailsState extends State<Product_details> {
  String senderName = '';
  String receiverName = '';
  String senderImage = '';
  String receiverImage = '';
  String senderAddress = '';
  String receiverAddress = '';
  String details = '';
  String order_image = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderById(); // เรียกข้อมูล order
  }

  Future<void> fetchOrderById() async {
    setState(() {
      isLoading = true;
    });

    try {
      // ดึง order ตาม orderId
      final doc = await FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.orderId)
          .get();

      if (!doc.exists) {
        setState(() => isLoading = false);
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      // ดึงข้อมูล user และ address
      final usersSnapshot =
          await FirebaseFirestore.instance.collection("users").get();
      final addressSnapshot =
          await FirebaseFirestore.instance.collection("address").get();

      Map<String, Map<String, dynamic>> userMap = {
        for (var u in usersSnapshot.docs) u.id: u.data() as Map<String, dynamic>,
      };

      Map<String, Map<String, dynamic>> addressMap = {
        for (var a in addressSnapshot.docs)
          a.id: a.data() as Map<String, dynamic>,
      };

      var senderData = userMap[data['sender_id']];
      var receiverData = userMap[data['receiver_id']];
      var senderAddressData = addressMap[data['sender_address_id']];
      var receiverAddressData = addressMap[data['receiver_address_id']];

      var senderAddressString = senderAddressData != null
          ? await getAddressFromLatLng(
              senderAddressData['latitude'], senderAddressData['longitude'])
          : "-";

      var receiverAddressString = receiverAddressData != null
          ? await getAddressFromLatLng(
              receiverAddressData['latitude'], receiverAddressData['longitude'])
          : "-";

      setState(() {
        senderName = senderData?['name'] ?? '-';
        receiverName = receiverData?['name'] ?? '-';
        senderImage = senderData?['profile_image'] ?? '';
        receiverImage = receiverData?['profile_image'] ?? '';
        details = data['details'] ?? '-';
        order_image = data['order_image'] ?? '';
        senderAddress = senderAddressString;
        receiverAddress = receiverAddressString;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching order: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // เพิ่มเมธอด getAddressFromLatLng
  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        final parts = [
          place.street,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea
        ].where((p) => p != null && p.toString().trim().isNotEmpty).toList();
        return parts.join(', ');
      }
      return '-';
    } catch (e) {
      debugPrint("Error reverse geocoding: $e");
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                      radius: 60,
                      backgroundColor: Colors.yellow,
                      foregroundImage: senderImage.isNotEmpty
                          ? NetworkImage(senderImage)
                          : const AssetImage('assets/images/pfboy.png')
                              as ImageProvider,
                    ),
                    const SizedBox(height: 8),
                    Text('ชื่อผู้ส่ง: $senderName'),
                  ],
                ),
                const Icon(Icons.arrow_forward, size: 32),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.yellow,
                      foregroundImage: receiverImage.isNotEmpty
                          ? NetworkImage(receiverImage)
                          : const AssetImage('assets/images/pfboy.png')
                              as ImageProvider,
                    ),
                    const SizedBox(height: 8),
                    Text('ชื่อผู้รับ: $receiverName'),
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
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 241, 241, 241),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image(
                      image: order_image.isNotEmpty
                          ? NetworkImage(order_image)
                          : const AssetImage('assets/images/box.png')
                              as ImageProvider,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'รายละเอียด',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(details),
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
