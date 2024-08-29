import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  SupabaseService();

  Future<UserResponse> getCurrentUser() async {
    return supabase.auth.getUser();
  }

  // get offline user
  User? get currentUser => supabase.auth.currentUser;

  Future<AuthResponse> login(String email, String password) async {
    return await supabase.auth
        .signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> register(
      String email, String password, String name) async {
    return await supabase.auth
        .signUp(email: email, password: password, data: {'display_name': name});
  }

  Future<UserResponse> updateUser(UserAttributes userAttributes) async {
    return await supabase.auth.updateUser(userAttributes);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  //TODO: delete user
  Future<void> deleteUser() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      await supabase.auth.admin.deleteUser(user.id);
    }
  }

  Future<List<Map<String, dynamic>>> fetchData(String table,
      {Map<String, dynamic>? equals, Map<String, dynamic>? inFilter}) async {
    var query = supabase.from(table).select();

    if (equals != null) {
      equals.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    if (inFilter != null) {
      inFilter.forEach((column, values) {
        query = query.inFilter(column, values);
      });
    }

    return await query;
  }

  Future<List<Map<String, dynamic>>> rpc(String function,
      {Map<String, dynamic>? params}) async {
    return await supabase.rpc(function, params: params);
  }
}
