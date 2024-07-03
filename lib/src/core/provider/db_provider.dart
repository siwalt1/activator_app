import 'package:activator_app/src/core/models/community.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:activator_app/src/core/services/appwrite_service.dart';
import 'package:appwrite/models.dart';

class DatabaseProvider with ChangeNotifier {
  final AppwriteService _appwriteService = AppwriteService();
  RealtimeSubscription? _realtimeSubscription;
  final List<Community> _communities = [];
  bool _isInitialized = false;

  List<Community> get communities => _communities;
  bool get isInitialized => _isInitialized;

  DatabaseProvider() {
    _initializeRealTimeSubscription();
  }

  Future<Document> createDocument(
      String databaseId, String collectionId, Map<String, dynamic> data) async {
    return await _appwriteService.createDocument(
        databaseId, collectionId, data);
  }

  Future<void> getCommunities() async {
    _communities.clear();
    try {
      final response = await _appwriteService.getDocuments(
          AppConstants.APPWRITE_DATABASE_ID,
          AppConstants.APPWRITE_COMMUNITIES_COLLECTION_ID);
      final communities = response.documents
          .map<Community>((doc) => Community.fromMap(doc.data))
          .toList();
      _communities.addAll(communities);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  _initializeRealTimeSubscription() async {
    final client = _appwriteService.client;
    final realtime = Realtime(client);

    await getCommunities();

    _realtimeSubscription = realtime.subscribe(
      [
        'databases.${AppConstants.APPWRITE_DATABASE_ID}.collections.${AppConstants.APPWRITE_COMMUNITIES_COLLECTION_ID}.documents'
      ],
    );

    _realtimeSubscription?.stream.listen((event) {
      // Handle the event
      if (event.events.contains(
          'databases.${AppConstants.APPWRITE_DATABASE_ID}.collections.${AppConstants.APPWRITE_COMMUNITIES_COLLECTION_ID}.documents.*.create')) {
        // Handle document creation
        final document = Document.fromMap(event.payload);
        final community = Community.fromMap(document.data);
        _communities.add(community);
        notifyListeners();
      } else if (event.events.contains(
          'databases.${AppConstants.APPWRITE_DATABASE_ID}.collections.${AppConstants.APPWRITE_COMMUNITIES_COLLECTION_ID}.documents.*.update')) {
        // Handle document update
        final document = Document.fromMap(event.payload);
        final community = Community.fromMap(document.data);
        final index =
            _communities.indexWhere((comm) => comm.id == community.id);
        if (index != -1) {
          _communities[index] = community;
          notifyListeners();
        }
      } else if (event.events.contains(
          'databases.${AppConstants.APPWRITE_DATABASE_ID}.collections.${AppConstants.APPWRITE_COMMUNITIES_COLLECTION_ID}.documents.*.delete')) {
        // Handle document deletion
        final document = Document.fromMap(event.payload);
        final community = Community.fromMap(document.data);
        _communities.removeWhere((comm) => comm.id == community.id);
        notifyListeners();
      }
      print(event.events);
    });

    _isInitialized = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeSubscription?.close();
    super.dispose();
  }
}
