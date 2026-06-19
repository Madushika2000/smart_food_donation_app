/// A single food donation created from the Donate Food screen.
///
/// This is a plain Dart class (a simple "model") that just holds the
/// values the user entered. It is kept in memory only for now — there is
/// no Firebase or database yet.
class Donation {
  final String title; // e.g. "Vegetable Rice"
  final String category; // e.g. "Cooked Meal"
  final String quantity; // e.g. "10 Packets"
  final String description; // free text about the food
  final String pickupLocation; // e.g. "Colombo, Sri Lanka"
  final String dateText; // ready-to-show line, e.g. "Pickup: 19 Jun 2026, 03:00 PM"
  final String imageUrl; // a preset food photo
  bool completed; // false = Ongoing tab, true = Completed tab

  Donation({
    required this.title,
    required this.category,
    required this.quantity,
    required this.description,
    required this.pickupLocation,
    required this.dateText,
    required this.imageUrl,
    this.completed = false,
  });
}
