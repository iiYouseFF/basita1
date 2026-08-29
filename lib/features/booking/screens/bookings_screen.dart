import 'package:flutter/material.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("حجوزاتي"),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          ],
          bottom: const TabBar(
            labelColor: Colors.blue,
            tabs: [
              Tab(text: "الحالية"),
              Tab(text: "السابقة"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // الحجوزات الحالية
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBookingCard(
                  "محمد وائل",
                  "فني تكيفات",
                  "12 أكتوبر, 2023",
                  "قيد التنفيذ",
                  true,
                ),
                _buildBookingCard(
                  "شمس ناجي",
                  "فني كهرباء معتمد ",
                  "15 أكتوبر, 2023",
                  "مؤكد",
                  false,
                ),
              ],
            ),
            // الحجوزات السابقة
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBookingCard(
                  "نور جمال",
                  "خدمات نجارة",
                  "5 أكتوبر, 2023",
                  "تم اكتماله",
                  false,
                  isPast: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    String name,
    String job,
    String date,
    String status,
    bool showTrack, {
    bool isPast = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(job),
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date),
              isPast
                  ? ElevatedButton(
                      onPressed: () {},
                      child: Text("إعادة طلب الخدمة"),
                    )
                  : ElevatedButton(
                      onPressed: () {},
                      child: Text(showTrack ? "تتبع الطلب" : "تعديل الموعد"),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
