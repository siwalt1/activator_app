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
        ]));
      }

      fetchTasks.add(Future.wait([_fetchUserProfiles()]));

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
      print('Events: ${event.events}');
      print('Realtime event: ${event.payload}');

      final Map<String, dynamic> payload = event.payload;
      final List<String> events = event.events; // List of events
      final String? collectionId = payload['\$collectionId'];

      // Handle user update event
      if (events.contains('users.*.update')) {
        _authProvider.updateUser();
      }
      // Handle community events
      else if (collectionId ==
          AppConstants.APPWRITE_COMMUNITIES_COLLECTION_ID) {
        final community = Community.fromMap(payload);
        if (events.contains('databases.*.collections.*.documents.*.create')) {
          _communities.add(community);
        } else if (events
            .contains('databases.*.collections.*.documents.*.update')) {
          _communities[_communities.indexWhere((c) => c.$id == community.$id)] =
              community;
        } else if (events
            .contains('databases.*.collections.*.documents.*.delete')) {
          _communities.removeWhere((c) => c.$id == community.$id);
        }
        notifyListeners();
      }
      // Handle userProfile events
      else if (collectionId ==
          AppConstants.APPWRITE_USER_PROFILES_COLLECTION_ID) {
        final userProfile = UserProfile.fromMap(payload);
        if (events.contains('databases.*.collections.*.documents.*.create') ||
            events.contains('databases.*.collections.*.documents.*.update')) {
          _userProfiles[userProfile.userId] = userProfile;
        } else if (events
            .contains('databases.*.collections.*.documents.*.delete')) {
          _userProfiles.remove(userProfile.userId);
        }
        notifyListeners();
      }
      // Handle community membership, activity, and attendance events
      else if (collectionId != null) {
        for (final community in _communities) {
          if (community.communityMembershipCollectionId == collectionId) {
            _updateMemberships(community, payload, events);
            break;
          } else if (community.activityCollectionId == collectionId) {
            _updateActivities(community, payload, events);
            break;
          } else if (community.activityAttendanceCollectionId == collectionId) {
            _updateAttendances(community, payload, events);
            break;
          }
        }
      }
    });

    _isInitialized = true;
    notifyListeners();
  }

  void _updateMemberships(
      Community community, Map<String, dynamic> payload, List<String> events) {
    print('Updating memberships');
    final membership = CommunityMembership.fromMap(payload);
    if (events.contains('databases.*.collections.*.documents.*.create')) {
      _communityMemberships[community.$id]?.add(membership);
    } else if (events
        .contains('databases.*.collections.*.documents.*.update')) {
      final memberships = _communityMemberships[community.$id];
      memberships?[memberships.indexWhere((m) => m.$id == membership.$id)] =
          membership;
    } else if (events
        .contains('databases.*.collections.*.documents.*.delete')) {
      _communityMemberships[community.$id]
          ?.removeWhere((m) => m.$id == membership.$id);
    }

    notifyListeners();
  }

  void _updateActivities(
      Community community, Map<String, dynamic> payload, List<String> events) {
    final activity = Activity.fromMap(payload);
    if (events.contains('databases.*.collections.*.documents.*.create')) {
      _activities[community.$id]?.add(activity);
    } else if (events
        .contains('databases.*.collections.*.documents.*.update')) {
      final activities = _activities[community.$id];
      activities?[activities.indexWhere((a) => a.$id == activity.$id)] =
          activity;
    } else if (events
        .contains('databases.*.collections.*.documents.*.delete')) {
      _activities[community.$id]?.removeWhere((a) => a.$id == activity.$id);
    }

    notifyListeners();
  }

  void _updateAttendances(
      Community community, Map<String, dynamic> payload, List<String> events) {
    final attendance = ActivityAttendance.fromMap(payload);
    if (events.contains('databases.*.collections.*.documents.*.create')) {
      _activityAttendances[community.$id]?.add(attendance);
    } else if (events
        .contains('databases.*.collections.*.documents.*.update')) {
      final attendances = _activityAttendances[community.$id];
      attendances?[attendances.indexWhere((a) => a.$id == attendance.$id)] =
          attendance;
    } else if (events
        .contains('databases.*.collections.*.documents.*.delete')) {
      _activityAttendances[community.$id]
          ?.removeWhere((a) => a.$id == attendance.$id);
    }

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
