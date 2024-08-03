import 'dart:async';

import 'package:activator_app/src/core/models/activity.dart';
import 'package:activator_app/src/core/models/activity_attendance.dart';
import 'package:activator_app/src/core/models/community.dart';
import 'package:activator_app/src/core/models/community_membership.dart';
import 'package:activator_app/src/core/models/user_profile.dart';
import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:appwrite/appwrite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:activator_app/src/core/services/appwrite_service.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/scheduler.dart';

class DatabaseProvider with ChangeNotifier {
  final AppwriteService _appwriteService;
  final AuthProvider _authProvider;
  RealtimeSubscription? _realtimeSubscription;

  final List<Community> _communities = [];
  final _communityMemberships = <String, List<CommunityMembership>>{};
  final _activities = <String, List<Activity>>{};
  final _activityAttendances = <String, List<ActivityAttendance>>{};
  final _userProfiles = <String, UserProfile>{};

  bool _isInitialized = false;
  bool _isConnected = false;

  List<Community> get communities => _communities;
  Map<String, List<CommunityMembership>> get communityMemberships =>
      _communityMemberships;
  Map<String, List<Activity>> get activities => _activities;
  Map<String, List<ActivityAttendance>> get activityAttendances =>
      _activityAttendances;
  Map<String, UserProfile> get userProfiles => _userProfiles;
  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;

  late final AppLifecycleListener appLifecycleListener;
  late final AppLifecycleState? appLifecycleState;
  late final StreamSubscription<List<ConnectivityResult>>
      connectivitySubscription;

  DatabaseProvider(this._appwriteService, this._authProvider) {
    _initialize();
  }

  void _initialize() {
    appLifecycleState = SchedulerBinding.instance.lifecycleState;
    appLifecycleListener = AppLifecycleListener(
      onDetach: () => {
        print('onDetach'),
        _realtimeSubscription?.close(),
        _realtimeSubscription = null,
      },
      onRestart: () => {
        print('onRestart'),
        if (_authProvider.user != null &&
            (_realtimeSubscription == null ||
                _realtimeSubscription!.controller.isClosed))
          _initializeRealTimeSubscription()
      },
      onHide: () => print('onHide'),
      onShow: () => print('onShow'),
      onInactive: () => print('onInactive'),
      onPause: () => print('onPause'),
      onResume: () => print('onResume'),
    );

    _authProvider.addListener(() {
      if (_authProvider.user != null) {
        print('#init_1: Reinitializing realtime subscription');
        _initializeRealTimeSubscription();
      } else {
        print('#init_2: Closing realtime subscription');
        _realtimeSubscription?.close();
        _realtimeSubscription = null;
        _isInitialized = false;

        _communities.clear();
        _communityMemberships.clear();
        _activities.clear();
        _activityAttendances.clear();
        _userProfiles.clear();

        notifyListeners();
      }
    });

    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    print('Connection status: $result');
    // final bool previousConnectionStatus = _isConnected;
    _isConnected =
        !(result.contains(ConnectivityResult.none) && result.length == 1);

    // if (_isConnected != previousConnectionStatus) {
    if (_isConnected && _authProvider.user != null) {
      print('Connected to the internet.');
      _realtimeSubscription?.close();
      _initializeRealTimeSubscription();
    } else {
      print('Lost internet connection.');
      _realtimeSubscription?.close();
      _realtimeSubscription = null;
    }
    notifyListeners();
    // }
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
      _sortCommunitiesByLastActivity();
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

  void _sortCommunitiesByLastActivity() {
    _communities.sort((a, b) {
      final aLastActivityDate = _activities[a.$id]?.isNotEmpty == true
          ? _activities[a.$id]!.last.startDate
          : DateTime.fromMillisecondsSinceEpoch(0);
      final bLastActivityDate = _activities[b.$id]?.isNotEmpty == true
          ? _activities[b.$id]!.last.startDate
          : DateTime.fromMillisecondsSinceEpoch(0);
      return bLastActivityDate.compareTo(aLastActivityDate);
    });
  }

  _initializeRealTimeSubscription() async {
    print('#init_3: Initializing realtime subscription');

    if (_isInitialized) {
      _isInitialized = false;
      notifyListeners();
    }

    final realtime = _appwriteService.realtime;

    await getCommunities();

    _realtimeSubscription = realtime.subscribe(
      [
        'account',
        'documents',
      ],
    );

    _realtimeSubscription?.stream.listen(
      (event) {
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
            int index = _communities.indexWhere((c) => c.$id == community.$id);
            if (index != -1) {
              _communities[index] = community;
            } else {
              _communities.add(community);
            }
          } else if (events
              .contains('databases.*.collections.*.documents.*.delete')) {
            _communities.removeWhere((c) => c.$id == community.$id);
          }
          _sortCommunitiesByLastActivity();
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
            } else if (community.activityAttendanceCollectionId ==
                collectionId) {
              _updateAttendances(community, payload, events);
              break;
            }
          }
          _sortCommunitiesByLastActivity();
          notifyListeners();
        }
      },
      onError: (e) {
        print('Realtime error: $e');
        if (_authProvider.user != null && isConnected) {
          _initializeRealTimeSubscription();
        }
      },
      cancelOnError: true,
      onDone: () => {
        print('Realtime subscription done at ${DateTime.now()}'),
        _realtimeSubscription = null,
        if (_authProvider.user != null && isConnected)
          _initializeRealTimeSubscription(),
      },
    );

    _realtimeSubscription!.controller.onCancel = () {
      DateTime nowStr = DateTime.now();
      print('Realtime subscription cancelled at $nowStr');
    };

    _isInitialized = true;
    notifyListeners();
  }

  void _updateMemberships(
      Community community, Map<String, dynamic> payload, List<String> events) {
    final membership = CommunityMembership.fromMap(payload);
    if (events.contains('databases.*.collections.*.documents.*.create')) {
      if (_communityMemberships[community.$id] == null) {
        _communityMemberships[community.$id] = [];
      }
      _communityMemberships[community.$id]?.add(membership);
    } else if (events
        .contains('databases.*.collections.*.documents.*.update')) {
      final memberships = _communityMemberships[community.$id];
      memberships?[memberships.indexWhere((m) => m.$id == membership.$id)] =
          membership;
    } else if (events
        .contains('databases.*.collections.*.documents.*.delete')) {
      if (membership.userId == _authProvider.user?.id) {
        _communities.removeWhere((c) => c.$id == community.$id);
        _activities.remove(community.$id);
        _activityAttendances.remove(community.$id);
        _communityMemberships.remove(community.$id);
      } else {
        _communityMemberships[community.$id]
            ?.removeWhere((m) => m.$id == membership.$id);
      }
    }

    // notifyListeners();
  }

  void _updateActivities(
      Community community, Map<String, dynamic> payload, List<String> events) {
    final activity = Activity.fromMap(payload);
    if (events.contains('databases.*.collections.*.documents.*.create')) {
      if (_activities[community.$id] == null) {
        _activities[community.$id] = [];
      }
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

    // notifyListeners();
  }

  void _updateAttendances(
      Community community, Map<String, dynamic> payload, List<String> events) {
    final attendance = ActivityAttendance.fromMap(payload);
    if (events.contains('databases.*.collections.*.documents.*.create')) {
      if (_activityAttendances[community.$id] == null) {
        _activityAttendances[community.$id] = [];
      }
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

    // notifyListeners();
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
    } catch (e) {
      rethrow;
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    try {
      await _appwriteService.leaveCommunity(communityId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createActivity(String communityId) async {
    try {
      await _appwriteService.createActivity(communityId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> leaveActivity(String communityId, String activityId) async {
    try {
      await _appwriteService.leaveActivity(communityId, activityId);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> resetInvitationToken(String communityId) async {
    try {
      String? updatedToken =
          await _appwriteService.resetInvitationToken(communityId);
      return updatedToken;
    } catch (e) {
      rethrow;
    }
  }

  Future<Community> fetchCommunity(String invitationToken) async {
    try {
      Community community =
          await _appwriteService.fetchCommunity(invitationToken);
      return community;
    } catch (e) {
      rethrow;
    }
  }
}
