import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MapAddress extends StatefulWidget {
  final String uid;
  const MapAddress({super.key, required this.uid});

  State<MapAddress> createState() => _MapAddressState();
}

class _MapAddressState extends State<MapAddress> {
  final mapController = MapController();
  LatLng? selectedLatLng;
  String? selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เลือกที่อยู่"),
        backgroundColor: const Color.fromARGB(255, 253, 225, 10),
        toolbarHeight: 90,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 227, 227, 227),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        selectedAddress ?? "กรุณาเลือกที่อยู่บนแผนที่",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: selectedLatLng == null
                      ? null
                      : () async {
                          final newAddress = {
                            "uid": widget.uid,
                            "address": selectedAddress,
                            "latitude": selectedLatLng!.latitude,
                            "longitude": selectedLatLng!.longitude,
                            "createdAt": FieldValue.serverTimestamp(),
                          };

                          await FirebaseFirestore.instance
                              .collection('address')
                              .add(newAddress);

                          Navigator.pop(context, newAddress);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 187, 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(70, 70),
                  ),
                  child:
                      const Text("บันทึก", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: const LatLng(16.246373, 103.251827), // กรุงเทพฯ
                initialZoom: 15.2,
                onTap: (tapPosition, point) async {
                  setState(() {
                    selectedLatLng = point;
                    selectedAddress = "กำลังดึงที่อยู่...";
                  });

                  final address = await getAddressFromLatLng(point);
                  setState(() {
                    selectedAddress = address;
                  });

                  log("📍 Address: $address");
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=1ef19f91909b4ac1ad3dfb1dc523a2c6',
                  userAgentPackageName: 'com.example.delivery',
                ),
                if (selectedLatLng != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedLatLng!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on,
                            color: Colors.red, size: 40),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getAddressFromLatLng(LatLng? latLng) async {
  if (latLng == null) return "ไม่พบพิกัด";

  try {
    final placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}"
          .replaceAll(", ,", ",");
    }
    return "ไม่พบที่อยู่";
  } catch (e) {
    return "เกิดข้อผิดพลาด: $e";
  }
}

}
