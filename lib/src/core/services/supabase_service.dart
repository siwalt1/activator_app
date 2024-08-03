import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  SupabaseService();

  // login
  Future<void> login(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  // logout
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<User?> getCurrentUser() async {
    return supabase.auth.currentUser;
  }

  // register user
  Future<void> register(String email, String password, String name) async {
    await supabase.auth
        .signUp(email: email, password: password, data: {'display_name': name});
  }

  // update user
  Future<UserResponse> updateUser(UserAttributes userAttributes) async {
    return await supabase.auth.updateUser(userAttributes);
  }

  // delete user
  Future<void> deleteUser() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      await supabase.auth.admin.deleteUser(user.id);
    }
  }

  // create a new document (assuming 'data' is a map of the columns and values)
  Future<void> createDocument(String table, Map<String, dynamic> data) async {
    final response = await supabase.from(table).insert(data);
    if (response.error != null) {
      throw response.error!.message;
    }
  }

  // get all documents
  Future<List<Map<String, dynamic>>> getDocuments(String table) async {
    final response = await supabase.from(table).select();
    return response;
  }

  // create community
  Future<void> createCommunity(
      String name, String description, int iconCode, String type) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      await createDocument('communities', {
        'name': name,
        'description': description,
        'icon_code': iconCode,
        'type': type,
        'creator_id': user.id
      });
    }
  }

  // leave community
  Future<void> leaveCommunity(String communityId) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      await supabase
          .from('community_members')
          .delete()
          .eq('community_id', communityId)
          .eq('user_id', user.id);
    }
  }

  // create activity
  Future<void> createActivity(String communityId, String name) async {
    await createDocument('activities', {
      'community_id': communityId,
      'name': name,
      'is_active': true,
    });
  }

  // leave activity
  Future<void> leaveActivity(String activityId) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      await supabase
          .from('activity_attendance')
          .delete()
          .eq('activity_id', activityId)
          .eq('user_id', user.id);
    }
  }

  // reset invitation token (stub, adjust as needed)
  Future<String?> resetInvitationToken(String communityId) async {
    // Implement your logic for resetting the invitation token
    return null;
  }

  // fetch community by invitation token (stub, adjust as needed)
  Future<Map<String, dynamic>> fetchCommunity(String invitationToken) async {
    // Implement your logic for fetching the community
    return {};
  }
}
