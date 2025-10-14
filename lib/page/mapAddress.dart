import 'dart:developer';

import 'package:delivery/page/registerUsers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class Mapaddress extends StatefulWidget {
  const Mapaddress({super.key});

  @override
  State<Mapaddress> createState() => _MapaddressState();
}

class _MapaddressState extends State<Mapaddress> {
  var mapController = MapController();
  LatLng? selectedLatLng;
  String? selectedAddress;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("เลือกที่อยู่"),
        backgroundColor: Color.fromARGB(255, 253, 225, 10),
        toolbarHeight: 90,
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 325,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 227, 227, 227),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal, // เลื่อนแนวนอน
                        child: Text(
                          selectedAddress ?? "กรุณาเลือกที่อยู่",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: getMap,
                  style: FilledButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 187, 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // มุมโค้ง
                    ),
                    minimumSize: Size(50, 70), // กว้าง 200 สูง 50
                  ),
                  child: Text("บันทึก", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),

            Expanded(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: LatLng(16.246373, 103.251827),
                  initialZoom: 15.2,
                  onTap: (tapPosition, point) async {
                    setState(() {
                      selectedLatLng = point; // เก็บพิกัดที่กดเลือก
                    });
                    String address = await getAddressFromLatLng(point);
                    log("ที่อยู่: $address");
                    log("${selectedLatLng}");

                    // ถ้าต้องการโชว์ในหน้า UI
                    setState(() {
                      selectedAddress = address;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=1ef19f91909b4ac1ad3dfb1dc523a2c6',
                    userAgentPackageName: 'com.example.delivery',
                  ),
                  if (selectedLatLng != null) // วางหมุดเฉพาะเมื่อมีค่าพิกัด
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedLatLng!,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
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

  void getMap() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Registerusers()),
    );
  }

  Future<String> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // คุณสามารถเลือกว่าจะใช้ city, street, name หรือ combination
        return "${place.street}, ${place.subLocality}, ${place.locality}";
      }
      return "ไม่พบที่อยู่";
    } catch (e) {
      return "เกิดข้อผิดพลาด: $e";
    }
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
