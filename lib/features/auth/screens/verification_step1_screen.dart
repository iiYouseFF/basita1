import 'package:flutter/material.dart';

class VerificationStep1Screen extends StatelessWidget {
  const VerificationStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "بسيطة",
          style: TextStyle(
            color: Color(0xFF0056D2),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("الخطوة 1 من 5", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.2,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF0056D2),
            ),
            const SizedBox(height: 25),

            const Text(
              "توثيق الهوية - الخطوة 1",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "يرجى رفع صورة واضحة لوجه بطاقة الرقم القومي",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, size: 50, color: Colors.blue),
                    const SizedBox(height: 10),
                    const Text(
                      "اضغط لالتقاط الصورة",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "أو اسحب الملف هنا",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // الحل هنا: وضعنا Expanded فقط داخل الـ Row
            Row(
              children: [
                Expanded(
                  child: _buildInstruction(
                    "إضاءة جيدة",
                    Icons.lightbulb_outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _buildInstruction("تركيز واضح", Icons.camera)),
              ],
            ),
            const SizedBox(height: 10),
            // هنا لا نستخدم Expanded لأنها ليست داخل Row
            _buildInstruction(
              "تجنب التغطية (لا تغط أي جزء من البطاقة)",
              Icons.block,
            ),

            const SizedBox(height: 25),

            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "مثال للصورة الصحيحة",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0056D2),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {},
          child: const Text(
            "التالي",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // الدالة المعدلة (ترجع Container بدلاً من Expanded)
  Widget _buildInstruction(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
