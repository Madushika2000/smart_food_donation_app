/// The lifecycle status of a food request.
///
/// A request starts as [open] (or [urgent]), becomes [inProgress] once a
/// donor steps in, and finally [fulfilled] when the food has been provided.
/// The Request Details screen shows this as a coloured badge and lets a
/// donor move it forward.
enum RequestStatus { open, urgent, inProgress, fulfilled }

/// A short, human-friendly label for each status (e.g. "In Progress").
extension RequestStatusLabel on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.open:
        return "Open";
      case RequestStatus.urgent:
        return "Urgent";
      case RequestStatus.inProgress:
        return "In Progress";
      case RequestStatus.fulfilled:
        return "Fulfilled";
    }
  }
}

/// A single food request posted by a charity / organization.
///
/// Like [Donation], this is a plain Dart model kept in memory only (no
/// backend yet). [status] is intentionally mutable so a donor accepting a
/// request updates it everywhere the same object is shown.
class FoodRequest {
  final String title; // e.g. "Meals for 20 People"
  final String org; // e.g. "by Charity Hub"
  final double lat; // pickup latitude
  final double lng; // pickup longitude
  final String imageUrl; // a food photo
  final String description; // free text about the request
  final String address; // human-readable pickup address
  final String neededItem; // e.g. "Cooked Meals"
  final String neededQuantity; // e.g. "20 Packets"
  final String postedAgo; // e.g. "2 hours ago"
  RequestStatus status; // changes as a donor steps in / fulfills it

  FoodRequest({
    required this.title,
    required this.org,
    required this.lat,
    required this.lng,
    required this.imageUrl,
    required this.description,
    required this.address,
    required this.neededItem,
    required this.neededQuantity,
    required this.postedAgo,
    this.status = RequestStatus.open,
  });
}
