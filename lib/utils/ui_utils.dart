import 'package:flutter/material.dart';

IconData getAppIcon(String iconName) {
  final iconMap = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'shopping_bag': Icons.shopping_bag,
    'movie': Icons.movie,
    'receipt': Icons.receipt,
    'local_hospital': Icons.local_hospital,
    'home': Icons.home,
    'school': Icons.school,
    'checkroom': Icons.checkroom,
    'phone_android': Icons.phone_android,
    'business': Icons.business,
    'more_horiz': Icons.more_horiz,
    'payments': Icons.payments,
    'card_giftcard': Icons.card_giftcard,
    'store': Icons.store,
    'trending_up': Icons.trending_up,
    'redeem': Icons.redeem,
    'category': Icons.category,
  };
  return iconMap[iconName] ?? Icons.category;
}

Color getAppColor(String colorName) {
  final colorMap = {
    'green': Colors.green,
    'blue': Colors.blue,
    'red': Colors.red,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'teal': Colors.teal,
    'pink': Colors.pink,
    'amber': Colors.amber,
  };
  return colorMap[colorName] ?? Colors.green;
}
