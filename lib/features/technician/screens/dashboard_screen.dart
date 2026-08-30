import 'package:flutter/material.dart';
import 'package:basita1/core/network/mock_backend.dart';
// removed: cloud_firestore - see docs/backend-prd.html

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الفني - طلبات الصيانة'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // الاستماع للتغييرات في مجموعة orders لحظياً
        stream: MockFirestore
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد طلبات صيانة متاحة حالياً',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;

              // استخراج بيانات الطلب
              final clientName = orderData['clientName'] ?? 'عميل';
              final serviceType = orderData['serviceType'] ?? 'خدمة عامة';
              final status = orderData['status'] ?? 'قيد الانتظار';
              final address = orderData['address'] ?? 'العنوان غير متوفر';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    serviceType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('العميل: $clientName'),
                      Text('العنوان: $address'),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(status),
                        backgroundColor: status == 'مكتمل'
                            ? Colors.green[100]
                            : Colors.orange[100],
                        labelStyle: TextStyle(
                          color: status == 'مكتمل'
                              ? Colors.green[800]
                              : Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: () {
                      // انتقال لتفاصيل الطلب أو قبول الطلب
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}