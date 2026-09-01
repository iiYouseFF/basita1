import '../services/api_client.dart';

class FamilyRepository {
  final ApiClient _api = ApiClient();

  Future<List<Map<String, dynamic>>> getFamilyMembers(String uid) async {
    final response = await _api.get('/users/$uid/family-members');
    final members = response['members'] as List? ?? [];
    return members.map((m) => m as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> addFamilyMember({
    required String uid,
    required String memberName,
    required String memberPhone,
    String? relationship,
  }) async {
    final body = <String, dynamic>{
      'memberName': memberName,
      'memberPhone': memberPhone,
    };
    if (relationship != null) body['relationship'] = relationship;
    
    return _api.post('/users/$uid/family-members', body: body);
  }

  Future<void> deleteFamilyMember(String uid, String memberId) async {
    await _api.delete('/users/$uid/family-members/$memberId');
  }

  Future<Map<String, dynamic>> joinFamily({
    required String phone,
    required String familyCode,
  }) async {
    return _api.post(
      '/families/join',
      body: {'phone': phone, 'familyCode': familyCode},
    );
  }

  Future<Map<String, dynamic>> getFamily(String code) async {
    return _api.get('/families/$code');
  }
}
