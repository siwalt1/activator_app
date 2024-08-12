import 'package:activator_app/src/core/utils/constants.dart';
import 'package:flutter/material.dart';

class ActivityTypeSelector extends StatelessWidget {
  const ActivityTypeSelector({
    super.key,
    required this.selectedActivityType,
    required this.onActivityTypeSelected,
  });

  final ActivityType? selectedActivityType;
  final ValueChanged<ActivityType> onActivityTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ActivityTypeItem(
          title: 'Solo',
          icon: Icons.person,
          isSelected: selectedActivityType == ActivityType.solo,
          onTap: () => {
            FocusScope.of(context).requestFocus(FocusNode()),
            onActivityTypeSelected(ActivityType.solo),
          },
        ),
        const SizedBox(width: AppConstants.separatorSpacing),
        ActivityTypeItem(
          title: 'Real-time',
          icon: Icons.group,
          isSelected: selectedActivityType == ActivityType.multi,
          onTap: () => {
            FocusScope.of(context).requestFocus(FocusNode()),
            onActivityTypeSelected(ActivityType.multi),
          },
        ),
      ],
    );
  }
}

class ActivityTypeItem extends StatelessWidget {
  const ActivityTypeItem({
    super.key,
    required this.onTap,
    required this.isSelected,
    required this.title,
    required this.icon,
  });

  final VoidCallback onTap;
  final bool isSelected;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Container(
            padding: const EdgeInsets.all(12.5),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: AppConstants.paddingSpacing),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
