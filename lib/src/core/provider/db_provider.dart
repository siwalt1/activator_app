import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:activator_app/src/core/services/appwrite_service.dart';
import 'package:appwrite/models.dart';

class DatabaseProvider with ChangeNotifier {
  final AppwriteService _appwriteService = AppwriteService();
  final AuthProvider _authProvider;
  RealtimeSubscription? _realtimeSubscription;
  final List<Team> _teams = [];
  final _teamMembers = <String, List<Membership>>{};
  bool _isInitialized = false;

  List<Team> get teams => _teams;
  Map<String, List<Membership>> get teamMembers => _teamMembers;
  bool get isInitialized => _isInitialized;

  DatabaseProvider(this._authProvider) {
    _initializeRealTimeSubscription();
  }

  Future<Document> createDocument(
      String databaseId, String collectionId, Map<String, dynamic> data) async {
    return await _appwriteService.createDocument(
        databaseId, collectionId, data);
  }

  Future<void> getTeams() async {
    try {
      // get all teams
      final TeamList teamsList = await _appwriteService.listTeams();
      _teams.clear();
      _teams.addAll(teamsList.teams);
      notifyListeners();

      // get all team members
      for (final team in _teams) {
        final MembershipList membershipList =
            await _appwriteService.listTeamMemberships(team.$id);
        // sort the members by name
        membershipList.memberships
            .sort((a, b) => a.userName.compareTo(b.userName));
        _teamMembers[team.$id] = membershipList.memberships;
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  _initializeRealTimeSubscription() async {
    final realtime = _appwriteService.realtime;
    final teams = _appwriteService.teams;

    await getTeams();

    _realtimeSubscription = realtime.subscribe(
      [
        'teams',
        'memberships',
        'account',
      ],
    );

    _realtimeSubscription?.stream.listen((event) {
      // user gets added to a team
      if (event.events.contains('teams.*.memberships.*.create')) {
        final membership = Membership.fromMap(event.payload);
        final teamId = membership.teamId;
        final index = _teamMembers[teamId]?.indexWhere(
          (mem) => mem.userId == membership.userId,
        );
        if (index == -1) {
          _teamMembers[teamId]?.add(membership);
          _teamMembers[teamId]
              ?.sort((a, b) => a.userName.compareTo(b.userName));
          notifyListeners();
        } else {
          _reinitializeRealTimeSubscription();
        }
      }
      // user gets removed from a team
      else if (event.events.contains('teams.*.memberships.*.delete')) {
        // if own membership is deleted, reinitialize the subscription
        print(event.payload['userId']);
        print(_authProvider.user?.$id);
        if (event.payload['userId'] == _authProvider.user?.$id) {
          _reinitializeRealTimeSubscription();
        } else {
          final membership = Membership.fromMap(event.payload);
          final teamId = membership.teamId;
          if (_teamMembers[teamId] != null) {
            _teamMembers[teamId]
                ?.removeWhere((mem) => mem.userId == membership.userId);
            notifyListeners();
          } else {
            _reinitializeRealTimeSubscription();
          }
        }
      }
      // team preferences get updated
      else if (event.events.contains('teams.*.update.prefs')) {
        final prefs = Preferences.fromMap(event.payload);
        RegExp regExp = RegExp(r"teams.([a-zA-Z0-9]+).update");
        String? teamId = event.events
            .map((event) => regExp.firstMatch(event))
            .firstWhere((match) => match != null, orElse: () => null)
            ?.group(1);

        final index = _teams.indexWhere((t) => t.$id == teamId);
        if (index != -1) {
          _teams[index] = Team(
            $id: _teams[index].$id,
            $createdAt: _teams[index].$createdAt,
            $updatedAt: _teams[index].$updatedAt,
            name: _teams[index].name,
            total: _teams[index].total,
            prefs: prefs,
          );
          notifyListeners();
        } else {
          _reinitializeRealTimeSubscription();
        }
      }

      // team name or general team data get updated
      else if (event.events.contains('teams.*.update') &&
          !event.events.contains('teams.*.update.prefs')) {
        final team = Team.fromMap(event.payload);
        final index = _teams.indexWhere((t) => t.$id == team.$id);
        if (index != -1) {
          _teams[index] = team;
          notifyListeners();
        } else {
          _reinitializeRealTimeSubscription();
        }
      }

      print('Event received: ${event.events}');
      print('Payload: ${event.payload}');
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
