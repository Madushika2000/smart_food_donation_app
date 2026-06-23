import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// The kind of event a notification is about.
///
/// The type decides which coloured icon is shown next to the notification,
/// so a donation update looks different from an urgent request, etc.
enum NotificationType { donation, request, reminder, general }

/// Icon + colours to display for each [NotificationType].
extension NotificationTypeStyle on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.donation:
        return Icons.volunteer_activism_outlined;
      case NotificationType.request:
        return Icons.priority_high;
      case NotificationType.reminder:
        return Icons.access_time;
      case NotificationType.general:
        return Icons.notifications_none;
    }
  }

  Color get foreground {
    switch (this) {
      case NotificationType.donation:
        return AppColors.primaryGreen;
      case NotificationType.request:
        return const Color(0xffD32F2F);
      case NotificationType.reminder:
        return const Color(0xffF57C00);
      case NotificationType.general:
        return const Color(0xff1565C0);
    }
  }

  Color get background {
    switch (this) {
      case NotificationType.donation:
        return AppColors.lightGreen;
      case NotificationType.request:
        return const Color(0xffFDECEC);
      case NotificationType.reminder:
        return const Color(0xffFFF3E0);
      case NotificationType.general:
        return const Color(0xffE3F2FD);
    }
  }
}

/// A single in-app notification shown on the Notifications screen.
///
/// Like [Donation] and [FoodRequest], this is a plain in-memory model (no
/// backend yet). [read] is mutable so tapping a notification can mark it as
/// read and update the unread badge on the dashboard bell.
class AppNotification {
  final String title; // e.g. "Donation added"
  final String body; // e.g. "Your donation 'Vegetable Rice' was added."
  final String timeAgo; // e.g. "2 hours ago"
  final NotificationType type; // decides the icon / colour
  bool read; // false = unread (shown with a dot)

  AppNotification({
    required this.title,
    required this.body,
    required this.timeAgo,
    this.type = NotificationType.general,
    this.read = false,
  });
}
