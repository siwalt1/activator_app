import 'package:activator_app/src/core/utils/constants.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class AppwriteService {
  final Client client = Client();
  late final Account account = Account(client);
  late final Databases databases = Databases(client);

  AppwriteService() {
    client
        .setEndpoint(AppConstants.APPWRITE_API_ENDPOINT)
        .setProject(AppConstants.APPWRITE_PROJECT_ID)
        .setSelfSigned(); // Remove in production
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
  Future<DocumentList> getDocuments(
      String databaseId, String collectionId) {
    return databases.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
    );
  }
}
