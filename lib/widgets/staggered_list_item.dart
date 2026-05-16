import 'package:flutter/material.dart';

/// A staggered layout item for transaction lists.
/// Used inside TabPerTanggal for calendar-based views.
class StaggeredListItem extends StatelessWidget {
  final Widget child;
  final int index;

  const StaggeredListItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Stagger effect: odd items are slightly indented
    final isOdd = index % 2 != 0;
    return Padding(
      padding: EdgeInsets.only(left: isOdd ? 16.0 : 0, right: isOdd ? 0 : 16.0),
      child: child,
    );
  }
}
