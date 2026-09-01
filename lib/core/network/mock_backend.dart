import 'dart:async';

// Mock backend - replaces Firebase/Supabase after extraction.
// Every method returns a permissive Future/Stream so existing UI keeps building.
// Real networking should use ApiClient (lib/core/network/api_client.dart).

class _Fake {
  @override
  dynamic noSuchMethod(Invocation inv) {
    final n = inv.memberName.toString();
    if (n.contains('currentUser')) return null;
    if (n.contains('snapshots')) return Stream<dynamic>.value([]);
    if (n.contains('get')) return Future<dynamic>.value(_MockSnapshot());
    if (n.contains('add')) return Future<dynamic>.value(_MockDocRef());
    if (n.contains('set') || n.contains('update') || n.contains('delete'))
      return Future<dynamic>.value(null);
    if (n.contains('where') ||
        n.contains('orderBy') ||
        n.contains('limit') ||
        n.contains('doc') ||
        n.contains('collection') ||
        n.contains('batch'))
      return _Fake();
    if (n.contains('verifyPhoneNumber') ||
        n.contains('signInWithCredential') ||
        n.contains('signOut'))
      return Future<dynamic>.value(null);
    if (n.contains('upload') ||
        n.contains('getPublicUrl') ||
        n.contains('storage') ||
        n.contains('from') ||
        n.contains('select') ||
        n.contains('insert') ||
        n.contains('rpc') ||
        n.contains('functions') ||
        n.contains('invoke'))
      return _Fake();
    return _Fake();
  }
}

class _MockSnapshot {
  List get docs => [];
  bool get exists => false;
  dynamic data() => {};
  Map<String, dynamic> dataMap() => {};
  dynamic operator [](String key) => null;
}

class _MockDocRef {
  String get id => 'mock_id';
}

class MockAuthException implements Exception {
  final String code;
  final String? message;
  MockAuthException({this.code = 'unknown', this.message});
}

class _MockAuthException extends MockAuthException {
  _MockAuthException({super.code, super.message});
}

class MockCredential {}

class _MockCredential extends MockCredential {}

class MockSetOptions {
  const MockSetOptions({bool merge = false});
}

class _MockSetOptions extends MockSetOptions {
  const _MockSetOptions.legacy({bool merge = false}) : super(merge: merge);
}

class MockFieldValue {
  static dynamic serverTimestamp() => DateTime.now();
  static dynamic increment(dynamic n) => n;
  static dynamic arrayUnion(dynamic l) => l;
  static dynamic arrayRemove(dynamic l) => l;
  static dynamic delete() => null;
}

class _MockFieldValue extends MockFieldValue {}

class FileOptions {
  const FileOptions({String? cacheControl, bool? upsert, String? contentType});
}

// Mocks for legacy type names so old files still compile
class FirebaseFirestore extends _Fake {
  static final FirebaseFirestore instance = FirebaseFirestore();
}

class FirebaseAuth extends _Fake {
  static final FirebaseAuth instance = FirebaseAuth();
}

class FirebaseStorage extends _Fake {
  static final FirebaseStorage instance = FirebaseStorage();
}

class Supabase extends _Fake {
  static final Supabase instance = Supabase();
}

class Timestamp {
  final DateTime _date;
  Timestamp.fromDate(this._date);
  static Timestamp now() => Timestamp.fromDate(DateTime.now());
  DateTime toDate() => _date;
  static Timestamp fromDateTime(DateTime d) => Timestamp.fromDate(d);
  int compareTo(Timestamp other) => _date.compareTo(other._date);
}

class Filter {
  Filter(
    dynamic field, {
    dynamic isEqualTo,
    dynamic isGreaterThan,
    dynamic arrayContains,
    dynamic isNotEqualTo,
    dynamic whereIn,
    dynamic arrayContainsAny,
  });
  static dynamic and(dynamic a, [dynamic b, dynamic c, dynamic d, dynamic e]) =>
      Filter('');
  static dynamic or(dynamic a, [dynamic b, dynamic c, dynamic d, dynamic e]) =>
      Filter('');
}

final dynamic MockFirestore = _Fake();
final dynamic MockAuth = _Fake();
final dynamic MockSupabase = _Fake();
final dynamic MockSupabaseInstance = _Fake();

// Type aliases so old type annotations still resolve
typedef DocumentSnapshot = dynamic;
typedef QuerySnapshot = dynamic;
typedef CollectionReference = dynamic;
typedef Query = dynamic;
typedef DocumentReference = dynamic;
typedef FirebaseAuthException = MockAuthException;
typedef PhoneAuthCredential = MockCredential;
typedef PhoneAuthProvider = MockCredential;
typedef SetOptions = MockSetOptions;
typedef FieldValue = MockFieldValue;

// Helpers for verifyPhoneNumber signature
class MockPhoneAuthProvider {
  static MockCredential credential({
    required String verificationId,
    required String smsCode,
  }) => MockCredential();
}

class MockFirebaseAuthException extends MockAuthException {
  MockFirebaseAuthException({super.code, super.message});
}
