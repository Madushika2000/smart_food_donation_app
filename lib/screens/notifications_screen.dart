import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../utils/colors.dart';
import '../utils/notification_store.dart';

/// Notifications screen (the in-app "inbox").
///
/// Opened from the bell button on the dashboard. It reads the shared
/// [NotificationStore], shows each notification with a coloured type icon,
/// marks them read on tap, and supports swipe-to-delete plus a
/// "mark all read" action. StatefulWidget so the list refreshes when a
/// notification is read or removed.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final List<AppNotification> items = NotificationStore.all;
    final bool hasUnread = NotificationStore.unreadCount > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // "Mark all read" — only enabled when there is something unread.
          if (items.isNotEmpty)
            TextButton(
              onPressed: hasUnread
                  ? () => setState(() => NotificationStore.markAllRead())
                  : null,
              child: Text(
                "Mark all read",
                style: TextStyle(
                  color: hasUnread ? AppColors.primaryGreen : Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: items.isEmpty ? _buildEmptyState() : _buildList(items),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            "No notifications yet.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<AppNotification> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildNotificationItem(items[index]),
    );
  }

  Widget _buildNotificationItem(AppNotification n) {
    return Dismissible(
      key: ObjectKey(n),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() => NotificationStore.remove(n));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification deleted")),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        // Tapping an unread notification marks it read.
        onTap: n.read ? null : () => setState(() => n.read = true),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            // Unread items get a subtle green tint so they stand out.
            color: n.read ? Colors.white : AppColors.lightGreen.withValues(alpha: 0.4),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coloured type icon.
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: n.type.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(n.type.icon, color: n.type.foreground, size: 22),
              ),
              const SizedBox(width: 14),

              // Title + body + time.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            n.read ? FontWeight.w600 : FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n.body,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n.timeAgo,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Unread dot.
              if (!n.read)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
