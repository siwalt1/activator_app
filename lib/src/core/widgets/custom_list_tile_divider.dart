import 'package:flutter/material.dart';

class CustomListTileDivider extends StatelessWidget {
  const CustomListTileDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Theme.of(context).dividerColor.withOpacity(0.4),
      thickness: 0.75,
      indent: 72,
      height: 0,
    );
  }
}
