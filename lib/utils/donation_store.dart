import '../models/donation.dart';

/// A very simple in-memory list of donations.
///
/// It works like [CurrentUser]: everything is `static`, so any screen can
/// read or add donations without passing objects around. There is no
/// database yet, so the list resets when the app is fully restarted.
///
/// The Donate Food screen calls [add] when the user submits, and the
/// My Donations screen reads [ongoing] / [completed] to show the list.
class DonationStore {
  DonationStore._(); // private constructor: this class is never instantiated

  // Some sample donations so the My Donations screen is not empty.
  static final List<Donation> _donations = [
    Donation(
      title: "Vegetable Rice",
      category: "Cooked Meal",
      quantity: "10 Packets",
      description: "Freshly cooked vegetable rice.",
      pickupLocation: "Colombo, Sri Lanka",
      dateText: "Pickup: 18 May 2024, 03:00 PM",
      imageUrl:
          "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200",
    ),
    Donation(
      title: "Fried Rice",
      category: "Cooked Meal",
      quantity: "15 Packets",
      description: "Chicken fried rice.",
      pickupLocation: "Gampaha, Sri Lanka",
      dateText: "Donated on 10 May 2024",
      imageUrl:
          "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200",
      completed: true,
    ),
    Donation(
      title: "Biryani",
      category: "Cooked Meal",
      quantity: "12 Packets",
      description: "Vegetable biryani.",
      pickupLocation: "Kandy, Sri Lanka",
      dateText: "Donated on 05 May 2024",
      imageUrl:
          "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=200",
      completed: true,
    ),
    Donation(
      title: "Fruits",
      category: "Fruits & Vegetables",
      quantity: "8 Packets",
      description: "Mixed seasonal fruits.",
      pickupLocation: "Galle, Sri Lanka",
      dateText: "Donated on 01 May 2024",
      imageUrl:
          "https://images.unsplash.com/photo-1519996529931-28324d5a630e?w=200",
      completed: true,
    ),
  ];

  /// All donations (newest first).
  static List<Donation> get all => _donations;

  /// Donations that are still in progress (shown on the "Ongoing" tab).
  static List<Donation> get ongoing =>
      _donations.where((d) => !d.completed).toList();

  /// Donations that are finished (shown on the "Completed" tab).
  static List<Donation> get completed =>
      _donations.where((d) => d.completed).toList();

  /// Adds a new donation to the top of the list.
  static void add(Donation donation) {
    _donations.insert(0, donation);
  }

  /// Removes a donation from the list (used by the delete button on the
  /// My Donations screen).
  static void remove(Donation donation) {
    _donations.remove(donation);
  }
}
