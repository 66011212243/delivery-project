import 'package:flutter/material.dart';

class HomePageUser extends StatefulWidget {
  const HomePageUser({super.key});

  @override
  State<HomePageUser> createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDE10A),
        toolbarHeight: 120,
        automaticallyImplyLeading: false,

        title: Container(
          height: 40, //ค้นหา
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "หมายเลขโทรศัพท์หรือที่อยู่",
              border: InputBorder.none, //ลบขอบค้นหา
              contentPadding: EdgeInsets.symmetric(vertical: 10), //9exsoj'8hosk
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16), //ระยะห่างของปุ่มจากด้านบน
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey), //กรอบ
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ), //ปุ่ม
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateOrderPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.local_shipping, color: Colors.yellow),
                label: const Text("ส่งสินค้า"),
              ),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // TODO: ไปหน้า "ดูสินค้าที่กำลังส่ง"
                },
                icon: const Icon(Icons.inventory, color: Colors.yellow),
                label: const Text("ดูสินค้าที่กำลังส่ง"),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFFDE10A),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
}

/// ------------------ หน้า ส่งสินค้า ------------------
class CreateOrderPage extends StatelessWidget {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final detailController = TextEditingController();
    final receiverController = TextEditingController();
    final addressController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDE10A),
        title: const Text(
          "สร้างรายการส่งสินค้าใหม่",
          style: TextStyle(color: Colors.black),
        ), //textbar
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูป
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.add, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  // ถ่ายรูปสินค้า
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("ถ่ายรูปสินค้า"),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "รายละเอียดสินค้า",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Product Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "ชื่อสินค้า",
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),

            // Quantity
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "จำนวน",
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),

            // Details
            TextField(
              controller: detailController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "รายละเอียดเพิ่มเติม (ไม่บังคับ)",
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),

            // Receiver
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: receiverController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "ค้นหาผู้รับสินค้า",
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    // TODO: ค้นหา
                  },
                  child: const Text("ค้นหา"),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Address
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      hintText: "เลือกที่อยู่ผู้รับ",
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    // TODO: เลือกที่อยู่
                  },
                  child: const Text("เลือก"),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Center(
                child: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      // ส่งสินค้า
                    },
                    child: const Text("ส่งสินค้า"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
