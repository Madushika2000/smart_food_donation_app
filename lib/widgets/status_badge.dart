import 'package:flutter/material.dart';
import '../models/food_request.dart';

/// A small coloured pill that shows a request's [RequestStatus].
///
/// Reused on both the Nearby Requests list and the Request Details screen so
/// the status looks identical everywhere. Colours: Open = green, Urgent =
/// red, In Progress = blue, Fulfilled = grey.
class StatusBadge extends StatelessWidget {
  final RequestStatus status;
  final double fontSize;

  const StatusBadge(this.status, {super.key, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    final _BadgeStyle s = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: s.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: fontSize + 3, color: s.foreground),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: s.foreground,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static _BadgeStyle _styleFor(RequestStatus status) {
    switch (status) {
      case RequestStatus.open:
        return const _BadgeStyle(
          Color(0xffE8F5E9), Color(0xff2E7D32), Icons.check_circle_outline);
      case RequestStatus.urgent:
        return const _BadgeStyle(
          Color(0xffFDECEC), Color(0xffD32F2F), Icons.priority_high);
      case RequestStatus.inProgress:
        return const _BadgeStyle(
          Color(0xffE3F2FD), Color(0xff1565C0), Icons.local_shipping_outlined);
      case RequestStatus.fulfilled:
        return const _BadgeStyle(
          Color(0xffEDEDED), Color(0xff616161), Icons.done_all);
    }
  }
}

/// Background colour, text/icon colour and icon for one status.
class _BadgeStyle {
  final Color background;
  final Color foreground;
  final IconData icon;
  const _BadgeStyle(this.background, this.foreground, this.icon);
}
