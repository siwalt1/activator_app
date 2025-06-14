import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:flutter/material.dart';

class CustomBottomSheetBody extends StatelessWidget {
  const CustomBottomSheetBody({
    super.key,
    this.title,
    required this.bottomSheetContext,
    this.initialFullScreen = false,
    this.isLoading = false,
    required this.child,
  });

  final String? title;
  final BuildContext bottomSheetContext;
  final bool initialFullScreen;
  final bool isLoading;
  final Widget child;

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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.borderRadius),
                      topRight: Radius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(height: AppConstants.paddingSpacing),
                      if (title != null)
                        Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: AppConstants.separatorSpacing),
                    ],
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppConstants.paddingSpacing,
                      right: AppConstants.paddingSpacing,
                    ),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: child,
                    ),
                  ),
                ),
              ],
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
