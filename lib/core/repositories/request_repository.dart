import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore repository for service requests.
/// Wraps all direct Firestore calls per Clean Architecture (no widget → Firestore).
class RequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('requests');

  CollectionReference<Map<String, dynamic>> _typedCollection(
    String? serviceType,
  ) {
    switch (serviceType?.toLowerCase()) {
      case 'carpentry':
      case 'نجارة':
        return _firestore.collection('carpentry_requests');
      case 'plumbing':
      case 'سباكة':
        return _firestore.collection('plumbing_requests');
      case 'painting':
      case 'نقاشة':
      case 'دهان':
        return _firestore.collection('painting_requests');
      default:
        return _requests;
    }
  }

  /// Create a new service request. Returns the generated document ID.
  Future<String> createRequest({
    required Map<String, dynamic> data,
    String? serviceType,
  }) async {
    try {
      // Ensure minimal required fields
      final payload = {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'status': data['status'] ?? 'pending',
      };
      final col = _typedCollection(serviceType);
      final ref = await col.add(payload);
      // Also mirror to generic requests collection if typed
      if (col != _requests) {
        await _requests.doc(ref.id).set({
          ...payload,
          'typedCollection': col.id,
        });
      }
      return ref.id;
    } catch (e) {
      // In Phase 4 this will route to FirebaseCrashlytics.recordError
      // ignore: avoid_print
      print('[RequestRepository.createRequest] $e');
      rethrow;
    }
  }

  Future<void> updateRequest(
    String requestId, {
    required Map<String, dynamic> data,
    String? serviceType,
  }) async {
    try {
      final col = _typedCollection(serviceType);
      await col.doc(requestId).update(data);
      // Keep generic mirror in sync if typed collection
      if (col != _requests) {
        try {
          await _requests.doc(requestId).update(data);
        } catch (_) {}
      }
    } catch (e) {
      // ignore: avoid_print
      print('[RequestRepository.updateRequest] $e');
      rethrow;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getRequest(
    String requestId,
  ) async {
    try {
      return await _requests.doc(requestId).get();
    } catch (e) {
      // ignore: avoid_print
      print('[RequestRepository.getRequest] $e');
      rethrow;
    }
  }

  /// Stream of a single request (for detail pages).
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchRequest(
    String requestId,
  ) {
    return _requests.doc(requestId).snapshots();
  }

  /// Customer: watch own requests by userId + status filter.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserRequests(
    String userId, {
    String? status,
  }) {
    var q = _requests
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);
    if (status != null)
      q = _firestore
          .collection('requests')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true);
    return q.snapshots();
  }

  /// Technician: watch pending requests in governorate.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchAvailableRequests(
    String governorate,
  ) {
    return _requests
        .where('status', isEqualTo: 'pending')
        .where('userGovernorate', isEqualTo: governorate)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Generic status update helper.
  Future<void> updateStatus(
    String requestId,
    String status, {
    Map<String, dynamic>? extra,
  }) async {
    final data = {'status': status, ...?extra};
    await updateRequest(requestId, data: data);
  }

  /// Delete request (owner only - Firestore rules enforce).
  Future<void> deleteRequest(String requestId) async {
    try {
      await _requests.doc(requestId).delete();
    } catch (e) {
      // ignore: avoid_print
      print('[RequestRepository.deleteRequest] $e');
      rethrow;
    }
  }
}
