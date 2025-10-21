import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/page/mapAddress.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class AddressPage extends StatefulWidget {
  final String uid;
  const AddressPage({super.key, required this.uid});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  List<Map<String, dynamic>> addressList = [];

  @override
  void initState() {
    super.initState();
    loadAddressFromFirestore();
  }

  Future<void> loadAddressFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('address')
        .where('uid', isEqualTo: widget.uid)
        .get();

    setState(() {
      addressList = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          "address": data['address'],
          "latLng": LatLng(data['latitude'], data['longitude']),
        };
      }).toList();
    });
  }

  Future<void> saveAddressToFirestore(Map<String, dynamic> data) async {
    // บันทึก
    await FirebaseFirestore.instance.collection('address').add({
      "uid": widget.uid,
      "address": data['address'],
      "latitude": data['latLng'].latitude,
      "longitude": data['latLng'].longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ที่อยู่"),
        backgroundColor: const Color.fromARGB(255, 253, 225, 10),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: addressList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  subtitle: Text(addressList[index]['address']),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapAddress(uid: widget.uid),
                  ),
                );

                if (result != null) {
                  final newAddress = {
                    "address": result['address'],
                    "latLng": result['latLng'],
                  };

                  // บันทึกลง Firestore
                  await saveAddressToFirestore(newAddress);

                  // โหลดข้อมูลใหม่จาก Firestore เพื่อให้โชว์รายการล่าสุด
                  await loadAddressFromFirestore();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
              ),
              child: const Text("เพิ่มที่อยู่"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
