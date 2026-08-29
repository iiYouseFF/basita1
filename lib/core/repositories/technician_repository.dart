import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore repository for technicians (doc ID = phone per firestore.rules).
class TechnicianRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('technicians');

  Future<DocumentSnapshot<Map<String, dynamic>>> getTechnician(
    String phone,
  ) async {
    try {
      return await _col.doc(phone).get();
    } catch (e) {
      // ignore: avoid_print
      print('[TechnicianRepository.getTechnician] $e');
      rethrow;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchTechnician(String phone) {
    return _col.doc(phone).snapshots();
  }

  /// Create or merge technician profile (phone is doc ID).
  Future<void> createOrUpdateTechnician({
    required String phone,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _col.doc(phone).set({
        ...data,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!data.containsKey('createdAt'))
          'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // ignore: avoid_print
      print('[TechnicianRepository.createOrUpdate] $e');
      rethrow;
    }
  }

  Future<void> updateTechnician(String phone, Map<String, dynamic> data) async {
    try {
      await _col.doc(phone).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore: avoid_print
      print('[TechnicianRepository.update] $e');
      rethrow;
    }
  }

  /// Increment wallet/earnings atomically.
  Future<void> creditWallet(
    String phone,
    double amount, {
    String? requestId,
  }) async {
    try {
      await _col.doc(phone).update({
        'walletBalance': FieldValue.increment(amount),
        'totalEarnings': FieldValue.increment(amount),
        'todayEarnings': FieldValue.increment(amount),
        'todayOrdersCount': FieldValue.increment(1),
        'lastEarningTimestamp': FieldValue.serverTimestamp(),
        if (requestId != null) 'lastRequestId': requestId,
      });
    } catch (e) {
      // ignore: avoid_print
      print('[TechnicianRepository.creditWallet] $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchByGovernorate(
    String governorate, {
    String? specialty,
  }) {
    var q = _col.where('governorate', isEqualTo: governorate);
    if (specialty != null) q = q.where('specialty', isEqualTo: specialty);
    return q.snapshots();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> searchTechnicians({
    String? governorate,
    String? specialty,
    int limit = 20,
  }) async {
    try {
      var q = _col.limit(limit) as Query<Map<String, dynamic>>;
      if (governorate != null)
        q = q.where('governorate', isEqualTo: governorate);
      if (specialty != null) q = q.where('specialty', isEqualTo: specialty);
      final snap = await q.get();
      return snap.docs;
    } catch (e) {
      // ignore: avoid_print
      print('[TechnicianRepository.search] $e');
      rethrow;
    }
  }
}
