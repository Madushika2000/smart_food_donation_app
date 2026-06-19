import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/current_user.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

/// Profile screen for the Smart Food Donation app.
///
/// This is a StatefulWidget so the user details can be CHANGED at runtime:
/// tapping "Edit Profile" opens the Edit screen, and when the user saves,
/// the new details are shown here. No Firebase / backend yet.
class ProfileScreen extends StatefulWidget {
  // OPTIONAL overrides. If you DON'T pass these, the screen shows the
  // logged-in user from CurrentUser (set during signup).
  final String? userName;
  final String? email;
  final String? phone;
  final String? userLocation;

  const ProfileScreen({
    super.key,
    this.userName,
    this.email,
    this.phone,
    this.userLocation,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // These hold the CURRENT details shown on screen. They start from the
  // values passed into the widget, and change when the user edits them.
  late String userName;
  late String email;
  late String phone;
  late String userLocation;

  @override
  void initState() {
    super.initState();
    // Use the passed-in values if given, otherwise the logged-in user.
    userName = widget.userName ?? CurrentUser.name;
    email = widget.email ?? CurrentUser.email;
    phone = widget.phone ?? CurrentUser.phone;
    userLocation = widget.userLocation ?? CurrentUser.location;
  }

  /// Opens the Edit Profile screen and waits for the updated details.
  /// If the user saved changes, we update the state so the new details show.
  Future<void> _openEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          name: userName,
          email: email,
          phone: phone,
          location: userLocation,
        ),
      ),
    );

    // result is null if the user just pressed back without saving.
    if (result != null && result is Map) {
      setState(() {
        userName = result['name'] as String;
        email = result['email'] as String;
        phone = result['phone'] as String;
        userLocation = result['location'] as String;
      });

      // Also save to CurrentUser (and the device) so the Home dashboard
      // shows the changes too, even after a restart.
      await CurrentUser.update(
        name: userName,
        email: email,
        phone: phone,
        location: userLocation,
      );
    }
  }

  /// Shows a confirmation dialog, then logs the user out by going to the
  /// Login screen and removing all previous screens (so the back button
  /// won't return to the app). No real auth/backend yet.
  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    // User tapped Cancel or dismissed the dialog.
    if (confirm != true) return;

    // Safety check: make sure this screen is still on screen after the dialog.
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false, // remove every previous screen
    );
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery gives us the device size so the layout is responsive.
    final Size screen = MediaQuery.of(context).size;
    final double screenWidth = screen.width;

    final double sidePadding = screenWidth * 0.05; // ~20px on a Pixel 6
    final double avatarRadius = screenWidth * 0.13; // scales with screen

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Quick edit button in the top-right corner.
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryGreen),
            onPressed: _openEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: sidePadding),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ----- TOP SECTION: photo, name, email, phone -----
            _buildHeader(avatarRadius),

            const SizedBox(height: 30),

            // ----- PROFILE MENU CARDS -----
            _buildMenuCard(
              icon: Icons.volunteer_activism_outlined,
              title: "My Donations",
              subtitle: "View donation history",
            ),
            _buildMenuCard(
              icon: Icons.assignment_outlined,
              title: "My Requests",
              subtitle: "View food requests",
            ),
            _buildMenuCard(
              icon: Icons.location_on_outlined,
              title: "My Address",
              subtitle: userLocation, // shows the Sri Lankan district
            ),
            _buildMenuCard(
              icon: Icons.notifications_none,
              title: "Notifications",
              subtitle: "Manage notifications",
            ),
            _buildMenuCard(
              icon: Icons.help_outline,
              title: "Help & Support",
              subtitle: "Get help and contact us",
            ),
            _buildMenuCard(
              icon: Icons.info_outline,
              title: "About Us",
              subtitle: "Learn more about the app",
            ),

            const SizedBox(height: 10),

            // ----- LOGOUT BUTTON (red) -----
            _buildLogoutButton(),

            // Extra space so the last item isn't hidden behind the nav bar.
            const SizedBox(height: 100),
          ],
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

  /// Top header: circular profile image placeholder, name, email, phone
  /// and an "Edit Profile" button.
  Widget _buildHeader(double avatarRadius) {
    return Column(
      children: [
        // Circular profile image placeholder (an icon, no network image).
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: AppColors.lightGreen,
          child: Icon(
            Icons.person,
            size: avatarRadius, // icon fills about half the circle
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 15),

        // Name
        Text(
          userName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),

        // Email
        Text(
          email,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 2),

        // Phone
        Text(
          phone,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 14),

        // Edit Profile button
        OutlinedButton.icon(
          onPressed: _openEditProfile,
          icon: const Icon(Icons.edit, size: 18, color: AppColors.primaryGreen),
          label: const Text(
            "Edit Profile",
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryGreen),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          ),
        ),
      ],
    );
  }

  /// A single rounded menu card with an icon, title and subtitle.
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
          // Circular icon badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 22),
          ),
          const SizedBox(width: 14),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Arrow on the right
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  /// Red logout button at the bottom of the menu (UI only).
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          "Logout",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  /// Bottom navigation bar (UI only). It has a notch for the center
  /// Donate (+) floating button. "Profile" is shown as the active tab.
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
            _buildNavItem(Icons.home_outlined, "Home"),
            _buildNavItem(Icons.assignment_outlined, "Requests"),
            const SizedBox(width: 40), // gap for the center FAB
            _buildNavItem(Icons.volunteer_activism_outlined, "My Donations"),
            _buildNavItem(Icons.person, "Profile", isActive: true),
          ],
        ),
      ),
    );
  }

  /// A single bottom-navigation item. [isActive] just changes the color
  /// so the "Profile" tab looks selected. No real navigation yet.
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
