import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/current_user.dart';

/// Home Dashboard screen for the Smart Food Donation app.
///
/// This is UI only (no backend, no navigation logic yet).
/// It is a StatelessWidget and uses MediaQuery so the layout
/// scales nicely on the Google Pixel 6 (and other phones).
class HomeScreen extends StatelessWidget {
  // OPTIONAL overrides. If you DON'T pass these, the screen shows the
  // logged-in user from CurrentUser (set during signup). Pass them only
  // if you want to force a specific name/location, e.g.
  //   HomeScreen(userName: "Nimal", userLocation: "Kandy, Sri Lanka")
  final String? userName;
  final String? userLocation;

  const HomeScreen({
    super.key,
    this.userName,
    this.userLocation,
  });

  // All 25 districts of Sri Lanka.
  //
  // This list is ready for later use (for example, to build a dropdown
  // so the user can pick their district). For now it is just a reference
  // of valid district names you can use for userLocation above.
  static const List<String> sriLankanDistricts = [
    "Colombo",
    "Gampaha",
    "Kalutara",
    "Kandy",
    "Matale",
    "Nuwara Eliya",
    "Galle",
    "Matara",
    "Hambantota",
    "Jaffna",
    "Kilinochchi",
    "Mannar",
    "Vavuniya",
    "Mullaitivu",
    "Batticaloa",
    "Ampara",
    "Trincomalee",
    "Kurunegala",
    "Puttalam",
    "Anuradhapura",
    "Polonnaruwa",
    "Badulla",
    "Monaragala",
    "Ratnapura",
    "Kegalle",
  ];

  // ----- IMAGE ASSETS -----
  // Custom cartoon illustrations (flat vector style) that match the app's
  // green theme. They live under assets/images/ and are declared in
  // pubspec.yaml, so they load instantly and work fully offline.
  static const String _bannerImg = "assets/images/banner.webp";
  static const String _mealsImg = "assets/images/meals.webp";
  static const String _bakeryImg = "assets/images/bakery.webp";
  static const String _veggiesImg = "assets/images/veggies.webp";

  @override
  Widget build(BuildContext context) {
    // MediaQuery gives us the device size so we can make the
    // layout responsive instead of using fixed numbers everywhere.
    final Size screen = MediaQuery.of(context).size;
    final double screenWidth = screen.width;

    // Horizontal padding scales a little with screen width.
    final double sidePadding = screenWidth * 0.05; // ~20px on a Pixel 6

    // Use the passed-in values if given, otherwise the logged-in user.
    final String displayName = userName ?? CurrentUser.firstName;
    final String displayLocation = userLocation ?? CurrentUser.location;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              // ----- TOP SECTION: location + notification -----
              _buildTopBar(displayLocation),

              const SizedBox(height: 25),

              // ----- GREETING -----
              // Greeting shows the logged-in user's first name.
              Text(
                "Hello, $displayName 👋",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Let's share food and help others",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),

              const SizedBox(height: 25),

              // ----- DONATION BANNER CARD -----
              _buildDonationBanner(screenWidth),

              const SizedBox(height: 30),

              // ----- HOW IT WORKS SECTION -----
              const Text(
                "How it works",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildHowItWorks(),

              const SizedBox(height: 30),

              // ----- NEARBY REQUESTS SECTION -----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Nearby Requests",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // "See All" is UI only for now.
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ----- REQUEST CARDS -----
              _buildRequestCard(
                imageUrl: _mealsImg,
                fallbackIcon: Icons.restaurant,
                title: "Meals for 10 People",
                org: "by Hope Foundation",
                distance: "500 m away",
              ),
              const SizedBox(height: 12),
              _buildRequestCard(
                imageUrl: _bakeryImg,
                fallbackIcon: Icons.bakery_dining,
                title: "Fresh Bakery Items",
                org: "by City Bakers",
                distance: "1.2 km away",
              ),
              const SizedBox(height: 12),
              _buildRequestCard(
                imageUrl: _veggiesImg,
                fallbackIcon: Icons.eco,
                title: "Vegetables & Fruits",
                org: "by Green Grocers",
                distance: "2.0 km away",
              ),

              // Extra space so the last card isn't hidden behind the nav bar.
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // ----- CENTER DONATE (+) BUTTON -----
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryGreen,
        shape: const CircleBorder(),
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ----- BOTTOM NAVIGATION (UI only) -----
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper widgets below. Splitting the UI into small methods keeps the
  // build() method readable and is beginner friendly.
  // ---------------------------------------------------------------------------

  /// Top bar with the location on the left and a notification icon on the right.
  Widget _buildTopBar(String location) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Location (uses the logged-in user's location)
        Row(
          children: [
            const Icon(Icons.location_on,
                color: AppColors.primaryGreen, size: 22),
            const SizedBox(width: 5),
            Text(
              location,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          ],
        ),
        // Notification icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_none, color: Colors.black87),
        ),
      ],
    );
  }

  /// Light green banner card with a message, a "Donate Now" button and
  /// a simple illustration placeholder (an icon).
  Widget _buildDonationBanner(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Text + button
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Every meal you share can bring a smile.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                  ),
                  child: const Text(
                    "Donate Now",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Food donation illustration
          Expanded(
            flex: 2,
            child: _foodImage(
              _bannerImg,
              width: double.infinity,
              height: screenWidth * 0.28, // responsive size
              fallbackIcon: Icons.volunteer_activism,
              radius: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Loads a local cartoon illustration from the app bundle, with a graceful
  /// fallback to the [fallbackIcon] if the asset is missing, so the dashboard
  /// never looks broken.
  Widget _foodImage(
    String assetPath, {
    required double width,
    required double height,
    required IconData fallbackIcon,
    double radius = 12,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: AppColors.lightGreen,
            alignment: Alignment.center,
            child: Icon(fallbackIcon,
                color: AppColors.primaryGreen, size: height * 0.4),
          );
        },
      ),
    );
  }

  /// "How it works" row: three circular icons with arrows in between.
  Widget _buildHowItWorks() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildWorkStep(Icons.fastfood, "Donate Food", "Post extra food"),
        _buildArrow(),
        _buildWorkStep(Icons.people_alt, "We Connect", "With NGOs"),
        _buildArrow(),
        _buildWorkStep(
            Icons.emoji_emotions, "They Receive", "And help people"),
      ],
    );
  }

  /// A small arrow shown between the "How it works" steps.
  Widget _buildArrow() {
    return const Padding(
      padding: EdgeInsets.only(top: 25),
      child: Icon(Icons.arrow_forward, color: Colors.grey, size: 18),
    );
  }

  /// A single circular step used inside "How it works".
  Widget _buildWorkStep(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          // Circular icon container
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// A nearby request card with a food image, details and a View button.
  Widget _buildRequestCard({
    required String imageUrl,
    required IconData fallbackIcon,
    required String title,
    required String org,
    required String distance,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Food image
          _foodImage(
            imageUrl,
            width: 80,
            height: 80,
            fallbackIcon: fallbackIcon,
          ),
          const SizedBox(width: 15),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  org,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(
                      distance,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // View button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: const Text("View", style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  /// Bottom navigation bar (UI only). It has a notch for the center
  /// Donate (+) floating button.
  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", isActive: true),
            _buildNavItem(Icons.assignment_outlined, "Requests"),
            const SizedBox(width: 40), // gap for the center FAB
            _buildNavItem(Icons.volunteer_activism_outlined, "My Donations"),
            _buildNavItem(Icons.person_outline, "Profile"),
          ],
        ),
      ),
    );
  }

  /// A single bottom-navigation item. [isActive] just changes the color
  /// so the "Home" tab looks selected. No real navigation yet.
  Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
    final Color color = isActive ? AppColors.primaryGreen : Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
