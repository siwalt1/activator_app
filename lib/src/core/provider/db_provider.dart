import 'dart:async';
import 'package:activator_app/src/core/models/activity.dart';
import 'package:activator_app/src/core/models/activity_attendance.dart';
import 'package:activator_app/src/core/models/community.dart';
import 'package:activator_app/src/core/models/community_member.dart';
import 'package:activator_app/src/core/models/profile.dart';
import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/core/services/supabase_service.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/utils/enum_converter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DatabaseProvider with ChangeNotifier {
  final SupabaseService _supabaseService;
  final AuthProvider _authProvider;
  RealtimeChannel? _realtimeChannel;

  final List<Community> _communities = <Community>[];
  final _communityMembers = <String, List<CommunityMember>>{};
  final _activities = <String, List<Activity>>{};
  final _activityAttendances = <String, List<ActivityAttendance>>{};
  final _profiles = <String, Profile>{};

  bool _isInitialized = false;
  bool _isConnected = false;

  List<Community> get communities => _communities;
  Map<String, List<CommunityMember>> get communityMembers => _communityMembers;
  Map<String, List<Activity>> get activities => _activities;
  Map<String, List<ActivityAttendance>> get activityAttendances =>
      _activityAttendances;
  Map<String, Profile> get profiles => _profiles;
  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;

  late final StreamSubscription<List<ConnectivityResult>>
      _connectivitySubscription;

  DatabaseProvider(this._supabaseService, this._authProvider) {
    _initialize();
  }

  void _initialize() {
    _authProvider.addListener(_authListener);
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results.first);
    });

    if (_authProvider.user != null) {
      _loadInitialData();
      _setupRealtimeSubscription();
    }
  }

  void _authListener() {
    if (_authProvider.user != null) {
      _loadInitialData();
      _setupRealtimeSubscription();
    } else {
      _clearData();
      _realtimeChannel?.unsubscribe();
      _realtimeChannel = null;
    }
  }

  Future<void> _loadInitialData() async {
    print('#1.0 Loading initial data...');
    final response = await _supabaseService.rpc('fetch_initial_data');

    if (response.isEmpty) {
      throw Exception('Failed to fetch initial data');
    }

    final List<dynamic> communities = response.first['communities'];
    final List<dynamic> communityMembers = response.first['community_members'];
    final List<dynamic> activities = response.first['activities'];
    final List<dynamic> activityAttendances = response.first['activity_attendances'];
    final List<dynamic> profiles = response.first['profiles'];

    _communities.addAll(
      communities.map((item) => Community.fromMap(item)).toList(),
    );

    _communityMembers.addAll(
      groupBy(
        communityMembers.map((item) => CommunityMember.fromMap(item)).toList(),
        (CommunityMember member) => member.communityId,
      ),
    );

    _activities.addAll(
      groupBy(
        activities.map((item) => Activity.fromMap(item)).toList(),
        (Activity activity) => activity.communityId,
      ),
    );

    _activityAttendances.addAll(
      groupBy(
        activityAttendances
            .map((item) => ActivityAttendance.fromMap(item))
            .toList(),
        (ActivityAttendance attendance) => attendance.activityId,
      ),
    );

    _profiles.addAll({
      for (var profile in profiles) profile['id']: Profile.fromMap(profile)
    });

    _sortCommunitiesByLastActivity();
    _isInitialized = true;
    notifyListeners();
  }

  void _clearData() {
    _communities.clear();
    _communityMembers.clear();
    _activities.clear();
    _activityAttendances.clear();
    _profiles.clear();
    _isInitialized = false;
    notifyListeners();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _isConnected = result != ConnectivityResult.none;

    if (_isConnected && _authProvider.user != null) {
      _setupRealtimeSubscription();
    } else {
      _realtimeChannel?.unsubscribe();
      _realtimeChannel = null;
    }
    notifyListeners();
  }

  void _setupRealtimeSubscription() {
    _realtimeChannel = _supabaseService.supabase.channel('schema-db-changes');

    _realtimeChannel
        ?.onPostgresChanges(
          schema: 'public',
          event: PostgresChangeEvent.all,
          callback: (payload) {
            print('Postgres change event received: ${payload.toString()}');
            // Handle the event based on the payload
            _handleDatabaseChangeEvent(payload);
          },
        )
        .subscribe();
  }

  Future<void> _handleDatabaseChangeEvent(PostgresChangePayload payload) async {
    final PostgresChangeEvent eventType = payload.eventType;
    final String table = payload.table;
    switch (eventType) {
      case PostgresChangeEvent.insert:
        await _handleInsertEvent(table, payload.newRecord);
        break;
      case PostgresChangeEvent.update:
        _handleUpdateEvent(table, payload.newRecord);
        break;
      case PostgresChangeEvent.delete:
        _handleDeleteEvent(table, payload.oldRecord);
        break;
      default:
        break;
    }
    _sortCommunitiesByLastActivity();
    notifyListeners();
  }

  Future<void> _handleInsertEvent(
      String table, Map<String, dynamic> newRecord) async {
    switch (table) {
      case 'communities':
        final newCommunity = Community.fromMap(newRecord);
        if (_communities.any((c) => c.id == newCommunity.id)) {
          return;
        }
        _communities.add(newCommunity);
        break;
      case 'community_members':
        final newMember = CommunityMember.fromMap(newRecord);
        if (!_communityMembers.containsKey(newMember.communityId)) {
          _communityMembers[newMember.communityId] = [];
        }
        if (_communityMembers[newMember.communityId]!
            .any((m) => m.userId == newMember.userId)) {
          return;
        }
        _communityMembers[newMember.communityId]!.add(newMember);
        if (newMember.userId != _authProvider.user!.id) {
          await _supabaseService.fetchData('profiles',
              equals: {'id': newMember.userId}).then((response) {
            if (response.isNotEmpty) {
              _profiles[newMember.userId] = Profile.fromMap(response.first);
            }
          });
        } else {
          await _fetchSingleCommunity(newMember.communityId);
        }
        break;
      case 'activities':
        final newActivity = Activity.fromMap(newRecord);
        if (!_activities.containsKey(newActivity.communityId)) {
          _activities[newActivity.communityId] = [];
        }
        if (_activities[newActivity.communityId]!
            .any((a) => a.id == newActivity.id)) {
          return;
        }
        _activities[newActivity.communityId]!.add(newActivity);
        break;
      case 'activity_attendances':
        final newAttendance = ActivityAttendance.fromMap(newRecord);
        if (!_activityAttendances.containsKey(newAttendance.activityId)) {
          _activityAttendances[newAttendance.activityId] = [];
        }
        if (_activityAttendances[newAttendance.activityId]!
            .any((a) => a.userId == newAttendance.userId)) {
          return;
        }
        _activityAttendances[newAttendance.activityId]!.add(newAttendance);
        break;
      case 'profiles':
        final newProfile = Profile.fromMap(newRecord);
        _profiles[newProfile.id] = newProfile;
        break;
    }
  }

  void _handleUpdateEvent(String table, Map<String, dynamic> updatedRecord) {
    switch (table) {
      case 'communities':
        final updatedCommunity = Community.fromMap(updatedRecord);
        final index =
            _communities.indexWhere((c) => c.id == updatedCommunity.id);
        if (index != -1) {
          _communities[index] = updatedCommunity;
        } else {
          _communities.add(updatedCommunity);
        }
        break;
      case 'community_members':
        final updatedMember = CommunityMember.fromMap(updatedRecord);
        if (_communityMembers.containsKey(updatedMember.communityId)) {
          final members = _communityMembers[updatedMember.communityId]!;
          final index = members.indexWhere((m) =>
              m.communityId == updatedMember.communityId &&
              m.userId == updatedMember.userId);
          if (index != -1) {
            members[index] = updatedMember;
          }
        } else {
          _communityMembers[updatedMember.communityId] = [updatedMember];
        }
        break;
      case 'activities':
        final updatedActivity = Activity.fromMap(updatedRecord);
        if (_activities.containsKey(updatedActivity.communityId)) {
          final activities = _activities[updatedActivity.communityId]!;
          final index =
              activities.indexWhere((a) => a.id == updatedActivity.id);
          if (index != -1) {
            activities[index] = updatedActivity;
          }
        } else {
          _activities[updatedActivity.communityId] = [updatedActivity];
        }
        break;
      case 'activity_attendances':
        final updatedAttendance = ActivityAttendance.fromMap(updatedRecord);
        if (_activityAttendances.containsKey(updatedAttendance.activityId)) {
          final attendances =
              _activityAttendances[updatedAttendance.activityId]!;
          final index = attendances.indexWhere((a) =>
              a.activityId == updatedAttendance.activityId &&
              a.userId == updatedAttendance.userId);
          if (index != -1) {
            attendances[index] = updatedAttendance;
          }
        } else {
          _activityAttendances[updatedAttendance.activityId] = [
            updatedAttendance
          ];
        }
        break;
      case 'profiles':
        final updatedProfile = Profile.fromMap(updatedRecord);
        _profiles[updatedProfile.id] = updatedProfile;
        if (updatedProfile.id == _authProvider.user!.id) {
          _authProvider.checkSession();
        }
        break;
    }
  }

  void _handleDeleteEvent(String table, Map<String, dynamic> oldRecord) {
    switch (table) {
      case 'communities':
        final String communityId = oldRecord['id'];
        _communities.removeWhere((c) => c.id == communityId);
        break;
      case 'community_members':
        final String communityId = oldRecord['community_id'];
        final String userId = oldRecord['user_id'];
        if (_communityMembers.containsKey(communityId)) {
          _communityMembers[communityId]!.removeWhere(
            (m) => m.communityId == communityId && m.userId == userId,
          );
          // Remove all activities and attendances for the user
          if (userId == _authProvider.user!.id) {
            _communities.removeWhere((c) => c.id == communityId);
            _activities[communityId]?.forEach((activity) {
              _activityAttendances.remove(activity.id);
            });
            _activities.remove(communityId);
          }
        }
        break;
      case 'activities':
        final String activityId = oldRecord['id'];
        _activities
            .removeWhere((key, value) => value.any((a) => a.id == activityId));
        break;
      case 'activity_attendances':
        final String activityId = oldRecord['activity_id'];
        final String userId = oldRecord['user_id'];
        if (_activityAttendances.containsKey(activityId)) {
          _activityAttendances[activityId]!.removeWhere(
              (a) => a.activityId == activityId && a.userId == userId);
        }
        break;
      case 'profiles':
        final oldProfileId = oldRecord['id'];
        _profiles.remove(oldProfileId);
        break;
    }
  }

  void _sortCommunitiesByLastActivity() {
    _communities.sort((a, b) {
      final aLastActivityDate = _activities[a.id]?.isNotEmpty == true
          ? _activities[a.id]!.last.startDate
          : DateTime.fromMillisecondsSinceEpoch(0);
      final bLastActivityDate = _activities[b.id]?.isNotEmpty == true
          ? _activities[b.id]!.last.startDate
          : DateTime.fromMillisecondsSinceEpoch(0);
      return bLastActivityDate.compareTo(aLastActivityDate);
    });
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _connectivitySubscription.cancel();
    _authProvider.removeListener(_authListener);
    super.dispose();
  }

  Future<void> createCommunity(
    String name,
    String description,
    int iconCode,
    ActivityType type,
    int activityDuration,
    NotificationType notificationType,
  ) async {
    final response = await _supabaseService.rpc('create_community', params: {
      'p_name': name,
      'p_description': description,
      'p_icon_code': iconCode,
      'p_type': EnumConverter.enumToString(type),
      'p_activity_duration': activityDuration,
      'p_notification_type': EnumConverter.enumToString(notificationType),
    });

    if (response.isEmpty) {
      throw Exception('Failed to create community');
    }

    final community = Community.fromMap(response.first['communities']);
    final member = CommunityMember.fromMap(response.first['members']);
    final activity = Activity.fromMap(response.first['activities']);
    final attendance =
        ActivityAttendance.fromMap(response.first['activity_attendances']);

    _communities.add(community);
    _communityMembers[community.id] = [member];
    _activities[community.id] = [activity];
    _activityAttendances[activity.id] = [attendance];

    _sortCommunitiesByLastActivity();
    notifyListeners();
  }

  Future<void> updateCommunity(
    String communityId,
    String name,
    String description,
    int iconCode,
    ActivityType type,
    int activityDuration,
    NotificationType notificationType,
  ) async {
    final response = await _supabaseService.rpc('update_community', params: {
      'p_community_id': communityId,
      'p_name': name,
      'p_description': description,
      'p_icon_code': iconCode,
      'p_type': EnumConverter.enumToString(type),
      'p_activity_duration': activityDuration,
      'p_notification_type': EnumConverter.enumToString(notificationType),
    });

    if (response.isEmpty) {
      throw Exception('Failed to update community');
    }

    final community = Community.fromMap(response.first['community']);

    final index = _communities.indexWhere((c) => c.id == communityId);
    if (index != -1) {
      _communities[index] = community;
    } else {
      _communities.add(community);
    }

    final stoppedActivities = response.first['stopped_activities']
        .map((a) => Activity.fromMap(a))
        .toList();
    final activities = _activities[community.id];
    if (activities != null) {
      for (var activity in stoppedActivities) {
        final index = activities.indexWhere((a) => a.id == activity.id);
        if (index != -1) {
          activities[index] = activity;
        }
      }
    }

    _sortCommunitiesByLastActivity();
    notifyListeners();
  }

  Future<void> leaveCommunity(String communityId, {String? userId}) async {
    userId ??= _authProvider.user!.id;

    final response = await _supabaseService.rpc(
      'leave_community',
      params: {
        'p_community_id': communityId,
        'p_user_id': userId,
      },
    );

    if (response.isEmpty) {
      throw Exception('Failed to leave community');
    }

    final deletedCommunity = response.first['deleted_community'] != null
        ? Community.fromMap(response.first['deleted_community'])
        : null;
    final leaverMember = response.first['leaver_member'] != null
        ? CommunityMember.fromMap(response.first['leaver_member'])
        : null;
    final leaverActivity = response.first['leaver_activity'] != null
        ? Activity.fromMap(response.first['leaver_activity'])
        : null;
    final activityAttendance = response.first['activity_attendance'] != null
        ? ActivityAttendance.fromMap(response.first['activity_attendance'])
        : null;

    if (deletedCommunity != null) {
      _communities.removeWhere((c) => c.id == deletedCommunity.id);
      _communityMembers.remove(deletedCommunity.id);
      _activities[deletedCommunity.id]?.forEach((activity) {
        _activityAttendances.remove(activity.id);
      });
      _activities.remove(deletedCommunity.id);
    } else {
      final members = _communityMembers[leaverMember!.communityId];
      if (members != null) {
        members.removeWhere((m) => m.userId == leaverMember.userId);
      }
      if (_activities.containsKey(leaverActivity!.communityId)) {
        _activities[leaverActivity.communityId]!.add(leaverActivity);
      } else {
        _activities[leaverActivity.communityId] = [leaverActivity];
      }
      if (!_activityAttendances.containsKey(activityAttendance!.activityId)) {
        _activityAttendances[activityAttendance.activityId] = [
          activityAttendance
        ];
      }
      _sortCommunitiesByLastActivity();
    }

    notifyListeners();
  }

  Future<void> createActivity(String communityId) async {
    final response = await _supabaseService.rpc(
      'create_join_activity',
      params: {'p_community_id': communityId},
    );

    if (response.isEmpty) {
      throw Exception('Failed to create activity');
    }

    final activity = Activity.fromMap(response.first['activities']);
    final attendance =
        ActivityAttendance.fromMap(response.first['activity_attendances']);

    if (_activities.containsKey(activity.communityId)) {
      final activities = _activities[activity.communityId]!;
      final index = activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        activities[index] = activity;
      }
    } else {
      _activities[activity.communityId] = [activity];
    }

    if (_activityAttendances.containsKey(attendance.activityId)) {
      final attendances = _activityAttendances[attendance.activityId]!;
      final index =
          attendances.indexWhere((a) => a.userId == attendance.userId);
      if (index != -1) {
        attendances[index] = attendance;
      }
    } else {
      _activityAttendances[attendance.activityId] = [attendance];
    }

    _sortCommunitiesByLastActivity();
    notifyListeners();
  }

  Future<void> leaveActivity(String communityId) async {
    final response = await _supabaseService.rpc(
      'stop_leave_activity',
      params: {'p_community_id': communityId},
    );

    if (response.isEmpty) {
      throw Exception('Failed to leave activity');
    }

    final stoppedActivity = response.first['stopped_activity'] != null
        ? Activity.fromMap(response.first['stopped_activity'])
        : null;
    final updatedAttendance = response.first['updated_attendance'] != null
        ? ActivityAttendance.fromMap(response.first['updated_attendance'])
        : null;

    if (stoppedActivity != null) {
      final activities = _activities[stoppedActivity.communityId];
      if (activities != null) {
        final index = activities.indexWhere((a) => a.id == stoppedActivity.id);
        if (index != -1) {
          activities[index] = stoppedActivity;
        }
      }
    }

    if (updatedAttendance != null) {
      final attendances = _activityAttendances[updatedAttendance.activityId];
      if (attendances != null) {
        final index =
            attendances.indexWhere((a) => a.userId == updatedAttendance.userId);
        if (index != -1) {
          attendances[index] = updatedAttendance;
        }
      }
    }

    _sortCommunitiesByLastActivity();
    notifyListeners();
  }

  Future<String?> resetInvitationToken(String communityId) async {
    final response = await _supabaseService.rpc(
      'reset_invitation_token',
      params: {'p_community_id': communityId},
    );
    return response[0]['new_token'];
  }

  Future<Community> fetchCommunity(String invitationToken) async {
    final response = await _supabaseService.rpc(
      'get_community_with_members_count',
      params: {'p_invitation_token': invitationToken},
    );

    if (response.isEmpty) {
      throw Exception('Community not found');
    }

    final communityData = response.first['community'];
    communityData['members_count'] = response.first['members_count'];

    return Community.fromMap(communityData);
  }

  Future<void> joinCommunity(String invitationToken) async {
    await _supabaseService.rpcVoid(
      'join_community',
      params: {'p_invitation_token': invitationToken},
    );
  }

  Future<void> _fetchSingleCommunity(String communityId) async {
    try {
      // Fetch the community by ID
      final communityResponse = _supabaseService
          .fetchData('communities', equals: {'id': communityId});

      // Fetch the community members and their profiles
      final membersProfilesFuture = (() async {
        final membersResponse = await _supabaseService.fetchData(
            'community_members',
            equals: {'community_id': communityId});

        final memberIds = membersResponse.map((m) => m['user_id']).toList();
        final profilesResponse = await _supabaseService.fetchData(
          'profiles',
          inFilter: {'id': memberIds},
        );

        return {
          'members': membersResponse,
          'profiles': profilesResponse,
        };
      })();

      // Fetch the activities and their attendances
      final activityAttendancesFuture = (() async {
        final activitiesResponse = await _supabaseService
            .fetchData('activities', equals: {'community_id': communityId});

        final activityIds = activitiesResponse.map((a) => a['id']).toList();
        final attendancesResponse = await _supabaseService.fetchData(
          'activity_attendances',
          inFilter: {'activity_id': activityIds},
        );

        return {
          'activities': activitiesResponse,
          'attendances': attendancesResponse,
        };
      })();

      final communityData = await communityResponse;
      final membersProfilesResponse = await membersProfilesFuture;
      final activityAttendancesResponse = await activityAttendancesFuture;

      final community = Community.fromMap(communityData.first);
      final members = (membersProfilesResponse['members'] as List?)
              ?.map((m) => CommunityMember.fromMap(m))
              .toList() ??
          [];
      final profiles = (membersProfilesResponse['profiles'] as List?)
              ?.map((p) => Profile.fromMap(p))
              .toList() ??
          [];
      final activities = (activityAttendancesResponse['activities'] as List?)
              ?.map((a) => Activity.fromMap(a))
              .toList() ??
          [];
      final attendances = (activityAttendancesResponse['attendances'] as List?)
              ?.map((a) => ActivityAttendance.fromMap(a))
              .toList() ??
          [];

      if (!_communities.any((c) => c.id == community.id)) {
        _communities.add(community);
      }
      _communityMembers[communityId] = members;
      for (var profile in profiles) {
        _profiles[profile.id] = profile;
      }
      _activities[communityId] = activities;
      for (var attendance in attendances) {
        if (!_activityAttendances.containsKey(attendance.activityId)) {
          _activityAttendances[attendance.activityId] = [];
        }
        _activityAttendances[attendance.activityId]!.add(attendance);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch community: $e');
      }
    }
  }
}
