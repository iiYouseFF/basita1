import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // تأكد من إضافة المكتبة في pubspec.yaml
import 'package:basita1/features/payment/screens/final_invoice_screen.dart';

// ==========================================
// 1. نماذج البيانات (Data Models)
// ==========================================
class MaterialItemModel {
  String name;
  double quantity;
  double unitPrice;

  MaterialItemModel({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class BasseytaItemModel {
  String name;
  double price;
  String imagePath;
  bool isChecked;

  BasseytaItemModel({
    required this.name,
    required this.price,
    required this.imagePath,
    this.isChecked = false,
  });
}

// ==========================================
// 2. الصفحة الرئيسية (StatefulWidget)
// ==========================================
class TaskSummaryScreen extends StatefulWidget {
  const TaskSummaryScreen({super.key});

  @override
  State<TaskSummaryScreen> createState() => _TaskSummaryScreenState();
}

class _TaskSummaryScreenState extends State<TaskSummaryScreen> {
  // الألوان الأساسية المطابقة للتصميم
  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color lightBlueText = Color(0xFF1D4ED8);
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color greyBg = Color(0xFFF3F4F6);
  static const Color badgeBg = Color(0xFFDBEAFE);

  // المتغيرات وحالة البيانات
  final double laborCost = 450.0;

  List<MaterialItemModel> materials = [
    MaterialItemModel(name: "شحن فريون R22", quantity: 1.5, unitPrice: 120.0),
  ];

  List<BasseytaItemModel> basseytaItems = [
    BasseytaItemModel(
      name: "خرطوم صرف 3 متر",
      price: 85.0,
      imagePath: 'assets/hose.png',
      isChecked: true,
    ),
    BasseytaItemModel(
      name: "مجموعة مسامير تثبيت",
      price: 25.0,
      imagePath: 'assets/screws.png',
      isChecked: false,
    ),
  ];

  // دالة حساب الإجمالي
  double _calculateTotalInvoice() {
    double total = laborCost;
    for (var item in materials) {
      total += item.total;
    }
    for (var item in basseytaItems) {
      if (item.isChecked) {
        total += item.price;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        // ==========================================
        // AppBar
        // ==========================================
        appBar: AppBar(
          backgroundColor: bgLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            "ملخص المهمة",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          // في وضع الـ RTL (العربي)، الـ leading بيظهر على اليمين
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryBlue),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          // لو حابب تضيف أي أيقونات على اليسار مستقبلاً، بتضيفها هنا في الـ actions
          actions: const [],
        ),

        // ==========================================
        // Body
        // ==========================================
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskDetailsCard(),
              const SizedBox(height: 24),

              Text(
                "تكلفة العمالة (ج.م)",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: lightBlueText,
                ),
              ),
              const SizedBox(height: 8),
              _buildLaborCost(),
              const SizedBox(height: 24),

              // الخامات المستخدمة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "الخامات المستخدمة",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // إضافة خامة جديدة فارغة
                      setState(() {
                        materials.add(
                          MaterialItemModel(
                            name: "خامة جديدة",
                            quantity: 1,
                            unitPrice: 0,
                          ),
                        );
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: primaryBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "إضافة خامة",
                          style: GoogleFonts.cairo(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // قائمة الخامات (ديناميكية)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: materials.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return DynamicMaterialCard(
                    item: materials[index],
                    onDelete: () {
                      setState(() {
                        materials.removeAt(index);
                      });
                    },
                    onUpdate: () {
                      setState(
                        () {},
                      ); // تحديث الفاتورة عند تغيير السعر أو الكمية
                    },
                  );
                },
              ),
              const SizedBox(height: 32),

              // خامات بسيطة
              Center(
                child: Column(
                  children: [
                    Text(
                      "خامات من \"بسيطة\"",
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                    Text(
                      "خامات تم شراؤها مسبقاً عبر التطبيق",
                      style: GoogleFonts.cairo(fontSize: 13, color: textGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // قائمة خامات بسيطة (ديناميكية)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: basseytaItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildBasseytaMaterialItem(basseytaItems[index]);
                },
              ),
              const SizedBox(height: 32),

              // إجمالي الفاتورة
              _buildTotalInvoiceCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),

        // ==========================================
        // Bottom Action Bar
        // ==========================================
        bottomNavigationBar: _buildBottomButtons(context),
      ),
    );
  }

  // ---------------------------------------------------------
  // دوال بناء العناصر المساعدة
  // ---------------------------------------------------------
  Widget _buildTaskDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "صيانة تكييف",
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: primaryBlue,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: textGrey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "المعادي، القاهرة",
                        style: GoogleFonts.cairo(fontSize: 12, color: textGrey),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "مهمة مكتملة",
                  style: GoogleFonts.cairo(
                    color: primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "العميل",
                      style: GoogleFonts.cairo(fontSize: 11, color: textGrey),
                    ),
                    Text(
                      "أحمد علي",
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "مدة العمل",
                      style: GoogleFonts.cairo(fontSize: 11, color: textGrey),
                    ),
                    Text(
                      "ساعتان (10:00 ص - 12:00 م)",
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLaborCost() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                laborCost.toInt().toString(),
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "ج.م",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Icon(Icons.lock_outline, color: textGrey, size: 24),
        ],
      ),
    );
  }

  Widget _buildBasseytaMaterialItem(BasseytaItemModel item) {
    return InkWell(
      onTap: () {
        setState(() {
          item.isChecked = !item.isChecked;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 50,
                height: 50,
                color: greyBg,
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                  Text(
                    "سعر التطبيق: ${item.price.toInt()} ج.م",
                    style: GoogleFonts.cairo(fontSize: 12, color: textGrey),
                  ),
                ],
              ),
            ),
            Container(
              decoration: item.isChecked
                  ? BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(6),
                    )
                  : BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
              width: 24,
              height: 24,
              child: item.isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalInvoiceCard() {
    double total = _calculateTotalInvoice();
    return CustomPaint(
      painter: DashedBorderPainter(
        color: const Color(0xFF60A5FA),
        radius: 16.0,
        strokeWidth: 1.5,
        dashPattern: const [8, 4],
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "إجمالي الفاتورة",
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "يتم إضافة ضريبة القيمة المضافة عند الدفع",
                  style: GoogleFonts.cairo(fontSize: 11, color: textGrey),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  total.toStringAsFixed(0),
                  style: GoogleFonts.cairo(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "ج.م",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5E7EB),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "حفظ",
                  style: GoogleFonts.cairo(
                    color: textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FinalInvoiceScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "مراجعة الطلب",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// 3. ويدجت خاصة بالخامات لتمكين التعديل الحي (Dynamic TextField Card)
// =====================================================================
class DynamicMaterialCard extends StatefulWidget {
  final MaterialItemModel item;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const DynamicMaterialCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<DynamicMaterialCard> createState() => _DynamicMaterialCardState();
}

class _DynamicMaterialCardState extends State<DynamicMaterialCard> {
  late TextEditingController qtyController;
  late TextEditingController priceController;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    qtyController = TextEditingController(
      text: widget.item.quantity == widget.item.quantity.toInt()
          ? widget.item.quantity.toInt().toString()
          : widget.item.quantity.toString(),
    );
    priceController = TextEditingController(
      text: widget.item.unitPrice == widget.item.unitPrice.toInt()
          ? widget.item.unitPrice.toInt().toString()
          : widget.item.unitPrice.toString(),
    );
    nameController = TextEditingController(text: widget.item.name);
  }

  @override
  void dispose() {
    qtyController.dispose();
    priceController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  onChanged: (val) => widget.item.name = val,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111827),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputColumn("الكمية", qtyController, (val) {
                  widget.item.quantity = double.tryParse(val) ?? 0;
                  widget.onUpdate();
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputColumn("سعر الوحدة", priceController, (val) {
                  widget.item.unitPrice = double.tryParse(val) ?? 0;
                  widget.onUpdate();
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "الإجمالي",
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.item.total
                            .toStringAsFixed(1)
                            .replaceAll(".0", ""),
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0056D2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputColumn(
    String label,
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            onChanged: onChanged,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF111827),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// 4. كلاس CustomPainter لرسم الإطار المتقطع
// =====================================================================
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final List<double> dashPattern;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (PathMetric measure in path.computeMetrics()) {
      double distance = 0.0;
      int index = 0;
      while (distance < measure.length) {
        final double len = dashPattern[index % dashPattern.length];
        if (index % 2 == 0) {
          dashPath.addPath(
            measure.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        index++;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
