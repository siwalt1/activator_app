import 'package:flutter/material.dart';
import 'package:activator_app/src/core/services/appwrite_service.dart';
import 'package:appwrite/models.dart';

class DatabaseProvider with ChangeNotifier {
  final AppwriteService _appwriteService = AppwriteService();

  Future<Document> createDocument(
      String databaseId, String collectionId, Map<String, dynamic> data) async {
    return await _appwriteService.createDocument(
        databaseId, collectionId, data);
  }
}
