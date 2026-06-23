import '../models/food_request.dart';

/// A very simple in-memory list of food requests.
///
/// It mirrors [DonationStore]: everything is `static`, so any screen can read
/// the same requests without passing the whole list around. Because each
/// [FoodRequest] is shared by reference, a status change made on the Request
/// Details screen is immediately reflected in the Nearby Requests list too.
/// There is no database yet, so the list resets on a full app restart.
class RequestStore {
  RequestStore._(); // private constructor: this class is never instantiated

  // Sample requests (around Colombo) with varied statuses so the status
  // feature is visible end-to-end.
  static final List<FoodRequest> _requests = [
    FoodRequest(
      title: "Meals for 20 People",
      org: "by Charity Hub",
      lat: 6.9271,
      lng: 79.8612,
      imageUrl:
          "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800",
      description:
          "We need cooked meals for 20 people in our shelter tonight. "
          "Any help with warm food would mean a lot to the families staying "
          "with us. Thank you!",
      address: "123, Galle Road, Colombo 03",
      neededItem: "Cooked Meals",
      neededQuantity: "20 Packets",
      postedAgo: "2 hours ago",
      status: RequestStatus.urgent,
    ),
    FoodRequest(
      title: "Food Packets Needed",
      org: "by Care Center",
      lat: 6.9344,
      lng: 79.8428,
      imageUrl:
          "https://images.unsplash.com/photo-1593113598332-cd288d649433?w=800",
      description:
          "Collecting dry ration packets for low-income families in the area. "
          "Rice, lentils and canned goods are especially welcome.",
      address: "45, Union Place, Colombo 02",
      neededItem: "Dry Rations",
      neededQuantity: "30 Packets",
      postedAgo: "5 hours ago",
      status: RequestStatus.open,
    ),
    FoodRequest(
      title: "Help for Shelter Home",
      org: "by Helping Hands",
      lat: 6.9147,
      lng: 79.8730,
      imageUrl:
          "https://images.unsplash.com/photo-1547573854-74d2a71d0827?w=800",
      description:
          "Breakfast support for 15 children at our shelter home. A donor is "
          "already helping with today's meals.",
      address: "78, Havelock Road, Colombo 05",
      neededItem: "Breakfast Meals",
      neededQuantity: "15 Packets",
      postedAgo: "Yesterday",
      status: RequestStatus.inProgress,
    ),
    FoodRequest(
      title: "Bakery Items for Kids",
      org: "by Smile Foundation",
      lat: 6.9490,
      lng: 79.8500,
      imageUrl:
          "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800",
      description:
          "Bread and bakery treats for an after-school program. This request "
          "has already been fulfilled — thank you to everyone who helped!",
      address: "12, Marine Drive, Colombo 06",
      neededItem: "Bakery Items",
      neededQuantity: "40 Pieces",
      postedAgo: "2 days ago",
      status: RequestStatus.fulfilled,
    ),
  ];

  /// All requests (the same shared objects every screen reads).
  static List<FoodRequest> get all => _requests;
}
