import '../models/app_notification.dart';

/// A very simple in-memory list of notifications.
///
/// It works like [DonationStore] and [RequestStore]: everything is `static`,
/// so any screen can read or add notifications without passing objects
/// around. There is no database yet, so the list resets when the app is
/// fully restarted.
///
/// Other screens call [add] when something happens (e.g. the Donate Food
/// screen after a donation is submitted), the dashboard bell reads
/// [unreadCount] for its badge, and the Notifications screen reads [all].
class NotificationStore {
  NotificationStore._(); // private constructor: never instantiated

  // Some sample notifications so the screen is not empty on first open.
  static final List<AppNotification> _notifications = [
    AppNotification(
      title: "Urgent request near you",
      body: '"Meals for 20 People" by Charity Hub needs help tonight.',
      timeAgo: "10 min ago",
      type: NotificationType.request,
    ),
    AppNotification(
      title: "Pickup reminder",
      body: 'Pickup for "Vegetable Rice" is scheduled today at 03:00 PM.',
      timeAgo: "2 hours ago",
      type: NotificationType.reminder,
    ),
    AppNotification(
      title: "Donation completed",
      body: 'Your donation "Fried Rice" was delivered. Thank you!',
      timeAgo: "Yesterday",
      type: NotificationType.donation,
      read: true,
    ),
    AppNotification(
      title: "Welcome to Smart Food Donation",
      body: "Share extra food and help people in need around you.",
      timeAgo: "2 days ago",
      type: NotificationType.general,
      read: true,
    ),
  ];

  /// All notifications (newest first).
  static List<AppNotification> get all => _notifications;

  /// How many notifications are still unread (used by the dashboard badge).
  static int get unreadCount => _notifications.where((n) => !n.read).length;

  /// Adds a new notification to the top of the list.
  static void add(AppNotification notification) {
    _notifications.insert(0, notification);
  }

  /// Marks every notification as read (clears the badge).
  static void markAllRead() {
    for (final n in _notifications) {
      n.read = true;
    }
  }

  /// Removes a single notification (used by swipe / delete).
  static void remove(AppNotification notification) {
    _notifications.remove(notification);
  }

  /// Clears the whole list.
  static void clear() {
    _notifications.clear();
  }
}
