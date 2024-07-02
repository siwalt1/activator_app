import 'package:activator_app/src/core/utils/constants.dart';
import 'package:flutter/material.dart';

class ActivityTypeSelector extends StatelessWidget {
  const ActivityTypeSelector({
    super.key,
    required this.selectedActivityType,
    required this.onActivityTypeSelected,
  });

  final ActivityType selectedActivityType;
  final ValueChanged<ActivityType> onActivityTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ActivityTypeItem(
          emojiTxt: '👤',
          title: 'Solo',
          isSelected: selectedActivityType == ActivityType.solo,
          onTap: () => onActivityTypeSelected(ActivityType.solo),
        ),
        const SizedBox(width: AppConstants.separatorSpacing),
        ActivityTypeItem(
          emojiTxt: '👥',
          title: 'Multi',
          isSelected: selectedActivityType == ActivityType.multi,
          onTap: () => onActivityTypeSelected(ActivityType.multi),
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
    required this.emojiTxt,
    required this.title,
  });

  final VoidCallback onTap;
  final bool isSelected;
  final String emojiTxt;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderOnForeground: true,
        elevation: 0,
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                children: [
                  Text(
                    emojiTxt,
                    style: const TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
