import 'package:activator_app/src/core/models/community.dart';
import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_button.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/core/widgets/custom_text_form_field.dart';
import 'package:activator_app/src/features/HomePage/home_page_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class InvitationView extends StatefulWidget {
  final String? invitationToken;

  const InvitationView({super.key, required this.invitationToken});

  static const routeName = '/invitation';

  @override
  State<InvitationView> createState() => _InvitationViewState();
}

class _InvitationViewState extends State<InvitationView> {
  bool _isLoading = true;
  Community? community;
  int? communityMemberships;

  @override
  void initState() {
    super.initState();
    _fetchCommunity();
  }

  void _fetchCommunity() async {
    // Fetch the community using the invitation token
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    try {
      community = await dbProvider.fetchCommunity(widget.invitationToken!);
    } catch (e) {
      print("Error fetching community: $e");
      if (!mounted) return;
      context.go(HomePageView.routeName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Community not found'),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _joinCommunity() async {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    try {
      await dbProvider.joinCommunity(widget.invitationToken!);
    } catch (e) {
      print("Error joining community: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to join community'),
        ),
      );
    }
    if (!mounted) return;
    context.go(HomePageView.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Community'),
      ),
      body: Stack(
        children: [
          if (community != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingSpacing),
                child: Center(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    clipBehavior: Clip.none,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          child: Icon(
                            IconData(community!.iconCode,
                                fontFamily: 'MaterialIcons'),
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: AppConstants.separatorSpacing),
                        Text(
                          community!.name,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '${community!.membersCount} ${community!.membersCount == 1 ? 'Member' : 'Members'}',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (community?.description?.isNotEmpty ?? false)
                          Column(
                            children: [
                              const SizedBox(
                                  height: AppConstants.separatorSpacing),
                              CustomTextFormField(
                                initialValue: community!.description!,
                                label: 'Description',
                                maxLines: null,
                                readOnly: true,
                              ),
                            ],
                          ),
                        const SizedBox(
                            height: AppConstants.separatorSpacing * 2),
                        const Text(
                          'Join the community to participate in community events.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.separatorSpacing),
                        CustomButton(
                          text: 'Join Community',
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          onPressed: _joinCommunity,
                        ),
                        // close button
                        const SizedBox(height: AppConstants.separatorSpacing),
                        CustomButton(
                          text: 'Close',
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          textColor: Theme.of(context).colorScheme.onSurface,
                          onPressed: () => context.go(HomePageView.routeName),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).padding.top +
                              AppBar().preferredSize.height,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_isLoading) const CustomProgressIndicator(),
        ],
      ),
    );
  }
}
