import 'dart:convert';

import 'package:activator_app/src/core/models/community.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class AppwriteService {
  final Client client = Client();
  late final Account account;
  late final Databases databases;
  late final Functions functions;
  late final Realtime realtime;

  AppwriteService() {
    client
        .setEndpoint(AppConstants.APPWRITE_API_ENDPOINT)
        .setProject(AppConstants.APPWRITE_PROJECT_ID);

    account = Account(client);
    databases = Databases(client);
    functions = Functions(client);
    realtime = Realtime(client);
  }

  // login
  Future<Session> login(String email, String password) {
    return account.createEmailPasswordSession(email: email, password: password);
  }

  // logout
  Future<void> logout() {
    return account.deleteSession(sessionId: 'current');
  }

  Future<User> getCurrentUser() async {
    final response = await account.get();
    return response;
  }

  Future<Jwt> getJWT() async {
    return await account.createJWT();
  }

  // register user
  Future<User> register(String email, String password, String name) {
    return account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }

  // update name
  Future<User> updateName(String name) {
    return account.updateName(name: name);
  }

  // update email
  Future<User> updateEmail(String email, String password) {
    return account.updateEmail(email: email, password: password);
  }

  // update password
  Future<User> updatePassword(String password, String oldPassword) {
    return account.updatePassword(password: password, oldPassword: oldPassword);
  }

  // create a new document
  Future<Document> createDocument(
      String databaseId, String collectionId, Map<String, dynamic> data) async {
    String userId = await getCurrentUser().then((user) => user.$id);
    return databases.createDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: ID.unique(),
      data: data,
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.write(Role.user(userId)),
      ],
    );
  }

  // get all documents
  Future<DocumentList> getDocuments(String databaseId, String collectionId) {
    return databases.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
    );
  }

  // create community
  Future<void> createCommunity(
      String name, String description, int iconCode, String type) async {
    try {
      final jwt = await getJWT().then((jwt) => jwt.jwt);
      print('JWT: $jwt');

      final response = await functions.createExecution(
        functionId: AppConstants.APPWRITE_CREATE_COMMUNITY_FUNCTION_ID,
        body: jsonEncode({
          'name': name,
          'description': description,
          'iconCode': iconCode,
          'type': type,
        }),
        headers: {
          'authorization': 'Bearer $jwt',
        },
      );

      if (response.responseStatusCode == 200) {
        print('Community created successfully');
      } else {
        print('Error creating community');
      }
    } catch (e) {
      rethrow;
    }
  }

  // leave community
  Future<void> leaveCommunity(String communityId) async {
    try {
      final jwt = await getJWT().then((jwt) => jwt.jwt);
      print('JWT: $jwt');

      final response = await functions.createExecution(
        functionId: AppConstants.APPWRITE_LEAVE_COMMUNITY_FUNCTION_ID,
        body: jsonEncode({
          'communityId': communityId,
        }),
        headers: {
          'authorization': 'Bearer $jwt',
        },
      );

      if (response.responseStatusCode == 200) {
        print('Community left successfully');
      } else {
        print('Error leaving community');
      }
    } catch (e) {
      rethrow;
    }
  }

  // create activity
  Future<void> createActivity(String communityId) async {
    try {
      final jwt = await getJWT().then((jwt) => jwt.jwt);
      print('JWT: $jwt');

      final response = await functions.createExecution(
        functionId: AppConstants.APPWRITE_CREATE_ACTIVITY_FUNCTION_ID,
        body: jsonEncode({
          'communityId': communityId,
        }),
        headers: {
          'authorization': 'Bearer $jwt',
        },
      );

      if (response.responseStatusCode == 200) {
        print('Created activity successfully');
      } else {
        print('Error creating activity');
      }
    } catch (e) {
      rethrow;
    }
  }

  // leave activity
  Future<void> leaveActivity(String communityId, String activityId) async {
    try {
      final jwt = await getJWT().then((jwt) => jwt.jwt);
      print('JWT: $jwt');

      final response = await functions.createExecution(
        functionId: AppConstants.APPWRITE_LEAVE_ACTIVITY_FUNCTION_ID,
        body: jsonEncode({
          'communityId': communityId,
          'activityId': activityId,
        }),
        headers: {
          'authorization': 'Bearer $jwt',
        },
      );

      if (response.responseStatusCode == 200) {
        print('Left activity successfully');
      } else {
        print('Error leaving activity');
      }
    } catch (e) {
      rethrow;
    }
  }

  // reset invitation token
  Future<String?> resetInvitationToken(String communityId) async {
    try {
      final jwt = await getJWT().then((jwt) => jwt.jwt);
      print('JWT: $jwt');

      final Execution response = await functions.createExecution(
        functionId: AppConstants.APPWRITE_RESET_INVITATION_TOKEN_FUNCTION_ID,
        body: jsonEncode({'communityId': communityId}),
        headers: {
          'authorization': 'Bearer $jwt',
        },
      );

      if (response.responseStatusCode == 200) {
        print('Invitation token reset successfully');
        var responseBody = jsonDecode(response.responseBody);
        return responseBody["invitationToken"];
      } else {
        print('Error resetting invitation token');
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  // fetch community by invitation token
  Future<Community> fetchCommunity(String invitationToken) async {
    try {
      final Execution response = await functions.createExecution(
        functionId:
            AppConstants.APPWRITE_FETCH_COMMUNITY_INVITATION_TOKEN_FUNCTION_ID,
        body: jsonEncode({'invitationToken': invitationToken}),
      );

      if (response.responseStatusCode == 200) {
        print('Community fetched successfully');
        var responseBody = jsonDecode(response.responseBody);
        return Community.fromMap(responseBody);
      } else {
        print('Error fetching community');
        throw Exception('Error fetching community');
      }
    } catch (e) {
      rethrow;
    }
  }
}
