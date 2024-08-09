import 'package:activator_app/src/core/utils/constants.dart';
import 'package:flutter/material.dart';

class InfoBoxes extends StatelessWidget {
  final List<IconLabelPair> items;

  const InfoBoxes({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(items.length * 2 - 1, (index) {
        if (index.isEven) {
          final item = items[index ~/ 2];
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  item.icon,
                  Text(
                    item.label,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox(width: AppConstants.separatorSpacing / 2);
        }
      }),
    );
  }
}

class IconLabelPair {
  final Icon icon;
  final String label;

  IconLabelPair({required this.icon, required this.label});
}
