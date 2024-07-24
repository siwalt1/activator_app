import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:flutter/material.dart';

class CustomBottomSheetBody extends StatelessWidget {
  const CustomBottomSheetBody({
    super.key,
    required this.child,
    required this.title,
    required this.bottomSheetContext,
    this.initialFullScreen = false,
    this.isLoading = false,
  });

  final Widget child;
  final String title;
  final BuildContext bottomSheetContext;
  final bool initialFullScreen;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: initialFullScreen ? 1 : null,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingSpacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.separatorSpacing),
                  Flexible(
                    child: SingleChildScrollView(
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: AppConstants.paddingSpacing / 2,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            if (isLoading) const CustomProgressIndicator()
          ],
        ),
      ),
    );
  }
}
