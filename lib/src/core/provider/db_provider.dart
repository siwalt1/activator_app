import 'package:activator_app/src/core/models/activity.dart';
import 'package:activator_app/src/core/models/activity_attendance.dart';
import 'package:activator_app/src/core/models/community.dart';
import 'package:activator_app/src/core/models/community_membership.dart';
import 'package:activator_app/src/core/models/user_profile.dart';
import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:activator_app/src/core/services/appwrite_service.dart';
import 'package:appwrite/models.dart';

class DatabaseProvider with ChangeNotifier {
  final AppwriteService _appwriteService = AppwriteService();
  final AuthProvider _authProvider;
  RealtimeSubscription? _realtimeSubscription;

  final List<Community> _communities = [];
  final _communityMemberships = <String, List<CommunityMembership>>{};
  final _activities = <String, List<Activity>>{};
  final _activityAttendances = <String, List<ActivityAttendance>>{};
  final _userProfiles = <String, UserProfile>{};

  bool _isInitialized = false;

  List<Community> get communities => _communities;
  Map<String, List<CommunityMembership>> get communityMemberships =>
      _communityMemberships;
  Map<String, List<Activity>> get activities => _activities;
  Map<String, List<ActivityAttendance>> get activityAttendances =>
      _activityAttendances;
  Map<String, UserProfile> get userProfiles => _userProfiles;
  bool get isInitialized => _isInitialized;

  DatabaseProvider(this._authProvider) {
    _initializeRealTimeSubscription();
  }

  Future<Document> createDocument(
      String databaseId, String collectionId, Map<String, dynamic> data) async {
    return await _appwriteService.createDocument(
        databaseId, collectionId, data);
  }

  Future<void> getCommunities() async {
    try {
      final DocumentList documentList = await _appwriteService.getDocuments(
        AppConstants.APPWRITE_DATABASE_ID,
        AppConstants.APPWRITE_COMMUNITIES_COLLECTION_ID,
      );
      _communities.clear();
      _communities.addAll(
          documentList.documents.map((doc) => Community.fromMap(doc.data)));

      final List<Future<void>> fetchTasks = [];

      for (final community in _communities) {
        fetchTasks.add(Future.wait([
          _fetchCommunityMemberships(community),
          _fetchActivities(community),
          _fetchActivityAttendances(community),
          _fetchUserProfiles(),
        ]));
      }

      await Future.wait(fetchTasks);

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchCommunityMemberships(Community community) async {
    final DocumentList membershipList = await _appwriteService.getDocuments(
      AppConstants.APPWRITE_DATABASE_ID,
      community.communityMembershipCollectionId,
    );
    _communityMemberships[community.$id] = membershipList.documents
        .map((doc) => CommunityMembership.fromMap(doc.data))
        .toList();
  }

  Future<void> _fetchActivities(Community community) async {
    final DocumentList activityList = await _appwriteService.getDocuments(
      AppConstants.APPWRITE_DATABASE_ID,
      community.activityCollectionId,
    );
    _activities[community.$id] = activityList.documents
        .map((doc) => Activity.fromMap(doc.data))
        .toList();
  }

  Future<void> _fetchActivityAttendances(Community community) async {
    final DocumentList attendanceList = await _appwriteService.getDocuments(
      AppConstants.APPWRITE_DATABASE_ID,
      community.activityAttendanceCollectionId,
    );
    _activityAttendances[community.$id] = attendanceList.documents
        .map((doc) => ActivityAttendance.fromMap(doc.data))
        .toList();
  }

  // fetch userProfiles
  Future<void> _fetchUserProfiles() async {
    final DocumentList documentList = await _appwriteService.getDocuments(
      AppConstants.APPWRITE_DATABASE_ID,
      AppConstants.APPWRITE_USER_PROFILES_COLLECTION_ID,
    );

    _userProfiles.clear();
    for (final doc in documentList.documents) {
      final userProfile = UserProfile.fromMap(doc.data);
      _userProfiles[userProfile.userId] = userProfile;
    }

    notifyListeners();
  }

  _initializeRealTimeSubscription() async {
    final realtime = _appwriteService.realtime;

    await getCommunities();

    _realtimeSubscription = realtime.subscribe(
      [
        'account',
        'documents',
      ],
    );

    _realtimeSubscription?.stream.listen((event) {
      // Handle the event
      
      print('Event: received: ${event.events}');
      print('Event: Payload: ${event.payload}');
    });

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _reinitializeRealTimeSubscription() async {
    _realtimeSubscription?.close();
    await _initializeRealTimeSubscription();
  }

  @override
  void dispose() {
    _realtimeSubscription?.close();
    super.dispose();
  }

  Future<void> createCommunity(
      String name, String description, int iconCode, String type) async {
    try {
      await _appwriteService.createCommunity(name, description, iconCode, type);
      await _reinitializeRealTimeSubscription();
    } catch (e) {
      print(e);
    }
  }
}
