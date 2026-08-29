// الفايل: dynamic_negotiation_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/features/offers/screens/offers_dashboard_screen.dart'; // عشان تقرأ الموديل

class DynamicNegotiationScreen extends StatefulWidget {
  final OfferModel offerData;
  final String requestId;

  const DynamicNegotiationScreen({super.key, required this.offerData, required this.requestId});

  @override
  State<DynamicNegotiationScreen> createState() => _DynamicNegotiationScreenState();
}

class _DynamicNegotiationScreenState extends State<DynamicNegotiationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تفاوض مع ${widget.offerData.name}", style: GoogleFonts.cairo()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // تقدر تحط الديزاين بتاعك هنا وتستخدم الداتا كده:
            Text("السعر المقترح: ${widget.offerData.price} ج.م", style: GoogleFonts.cairo(fontSize: 20)),
            Text("خبرة: ${widget.offerData.experienceYears} سنوات", style: GoogleFonts.cairo()),
          ],
        ),
      ),
    );
  }
}