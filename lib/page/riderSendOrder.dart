import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Ridersendorder extends StatefulWidget {
  String order_id;
  Ridersendorder({super.key, required this.order_id});

  @override
  State<Ridersendorder> createState() => _RidersendorderState();
}

class _RidersendorderState extends State<Ridersendorder> {
  @override
  void initState() {
    super.initState();
  }

  int activeStep = 2;

  void _showDriverInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ให้ popup สูงได้มาก
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ขนาดตามเนื้อหา
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/khong2.png'),
            ),
            const SizedBox(height: 12),
            const Text(
              'ขยัน คงรวย',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('ไรเดอร์จัดส่งสินค้า'),
            const SizedBox(height: 8),
            const Text('📞 094-456-****'),
            const Text('🚘 หมายเลขทะเบียน: กข 1628'),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // ปิด popup
                setState(() {
                  activeStep = (activeStep + 1) % 4;
                });
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('พัสดุถูกจัดส่งแล้ว'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  var mapController = MapController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.order_id)),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: LatLng(16.246373, 103.251827),
                  initialZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=1ef19f91909b4ac1ad3dfb1dc523a2c6',
                    userAgentPackageName: 'com.example.delivery',
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Image.asset('assets/images/khong2.png', height: 120),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _showDriverInfo,
                          icon: const Icon(Icons.person_outline),
                          label: const Text('ดูข้อมูลไรเดอร์'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[700],
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
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
