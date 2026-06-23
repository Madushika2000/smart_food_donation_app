import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/food_request.dart';
import '../utils/colors.dart';
import '../widgets/status_badge.dart';
import 'donation_summary_screen.dart';

/// Shows the full details of a single [FoodRequest], including its real,
/// live status.
///
/// The status is not just decoration: the bottom button performs a real
/// state change — Open/Urgent → In Progress ("I can donate") → Fulfilled
/// ("Mark as Fulfilled"). Because the [FoodRequest] is shared by reference
/// (via RequestStore), the change is reflected on the Nearby Requests list
/// when the user goes back.
class RequestDetailsScreen extends StatefulWidget {
  /// The request to show.
  final FoodRequest request;

  /// Optional pre-computed distance label (e.g. "0.5 km away") from the
  /// Nearby Requests screen. Hidden when null (e.g. opened from Home).
  final String? distanceLabel;

  const RequestDetailsScreen({
    super.key,
    required this.request,
    this.distanceLabel,
  });

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  FoodRequest get _request => widget.request;

  /// Moves the request to [next] status and confirms with a green SnackBar.
  void _changeStatus(RequestStatus next, String message) {
    setState(() => _request.status = next);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng pickupLocation = LatLng(_request.lat, _request.lng);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image (with a graceful fallback if it fails to load).
                  Image.network(
                    _request.imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: const Color(0xffF1F8E9),
                      child: const Icon(Icons.restaurant,
                          size: 80, color: AppColors.primaryGreen),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + posted time.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _request.title,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    _request.org,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  _request.postedAgo,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Real status badge + (optional) distance.
                        Row(
                          children: [
                            StatusBadge(_request.status),
                            if (widget.distanceLabel != null) ...[
                              const SizedBox(width: 10),
                              const Icon(Icons.location_on_outlined,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 2),
                              Text(
                                widget.distanceLabel!,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 25),
                        // About Request
                        const Text(
                          "About Request",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _request.description,
                          style: const TextStyle(
                            color: Colors.black87,
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 25),
                        // What they need
                        const Text(
                          "What they need",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xffF5F7FA),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.radio_button_checked,
                                      color: AppColors.primaryGreen, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    _request.neededItem,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              Text(
                                _request.neededQuantity,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        // Pickup Location
                        const Text(
                          "Pickup Location",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on,
                                color: AppColors.primaryGreen, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _request.address,
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // Real map centred on this request's pickup location.
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.2)),
                            ),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: pickupLocation,
                                initialZoom: 15,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none, // static-like
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.smart_food_donation_app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: pickupLocation,
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.topCenter,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: AppColors.primaryGreen,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom action button — drives the real status transition.
          _buildActionButton(),
        ],
      ),
    );
  }

  /// The bottom button whose label/action depend on the current status.
  Widget _buildActionButton() {
    final RequestStatus status = _request.status;

    late final String label;
    late final IconData icon;
    VoidCallback? onPressed;

    switch (status) {
      case RequestStatus.open:
      case RequestStatus.urgent:
        label = "I can donate";
        icon = Icons.volunteer_activism;
        onPressed = () {
          _changeStatus(
            RequestStatus.inProgress,
            "Thank you! You're now donating to this request.",
          );
          // Navigate to the summary screen for confirmation
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DonationSummaryScreen()),
          );
        };
        break;
      case RequestStatus.inProgress:
        label = "Mark as Fulfilled";
        icon = Icons.done_all;
        onPressed = () => _changeStatus(
              RequestStatus.fulfilled,
              "Marked as fulfilled. You're a lifesaver! 🎉",
            );
        break;
      case RequestStatus.fulfilled:
        label = "Already Fulfilled";
        icon = Icons.check_circle;
        onPressed = null; // disabled
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon,
              color: onPressed == null ? Colors.grey.shade600 : Colors.white,
              size: 20),
          label: Text(
            label,
            style: TextStyle(
              color: onPressed == null ? Colors.grey.shade600 : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
