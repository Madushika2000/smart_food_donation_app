import 'package:flutter/material.dart';
import '../models/food_request.dart';
import '../utils/colors.dart';
import '../utils/current_user.dart';
import '../utils/notification_store.dart';
import '../utils/request_store.dart';
import '../widgets/app_network_image.dart';
import '../widgets/status_badge.dart';
import 'donate_food_screen.dart';
import 'my_donations_screen.dart';
import 'nearby_requests_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'request_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  /// Route name for the dashboard. Used so flows that rebuild the navigation
  /// stack (e.g. confirming a donation on DonationSummaryScreen) can return
  /// here instead of the splash screen.
  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  /// Opens the full details for [r], then refreshes so a status change made
  /// there is reflected on the dashboard card too.
  Future<void> _openRequest(FoodRequest r) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RequestDetailsScreen(request: r)),
    );
    if (mounted) setState(() {});
  }

  /// Opens the Notifications screen, then refreshes so the unread badge on
  /// the bell updates after the user reads/clears notifications.
  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // The request featured on the dashboard (also opens in full on tap).
    final FoodRequest featured = RequestStore.all.first;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              // Location and Notification Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.black, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        CurrentUser.location,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                    ],
                  ),
                  // Notification bell — opens the Notifications screen and
                  // shows a red badge with the number of unread items.
                  GestureDetector(
                    onTap: _openNotifications,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none, color: Colors.black),
                        ),
                        if (NotificationStore.unreadCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "${NotificationStore.unreadCount}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Welcome Text — shows the real logged-in user's first name
              // (set during signup and stored in CurrentUser).
              Text(
                "Hello, ${CurrentUser.firstName} 👋",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Let's share food and help others",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 25),
              // Donation Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xffE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
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
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const DonateFoodScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryGreen,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            child: const Text("Donate Now", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Icon(Icons.volunteer_activism, size: 80, color: AppColors.primaryGreen.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // How it works Section
              const Text(
                "How it works",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWorkStep(Icons.redeem, "Donate Food", "Post extra food"),
                  const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                  _buildWorkStep(Icons.people_outlined, "We Connect", "with NGOs"),
                  const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                  _buildWorkStep(Icons.emoji_emotions_outlined, "They Receive", "and help people"),
                ],
              ),
              const SizedBox(height: 30),
              // Nearby Requests Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Nearby Requests",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const NearbyRequestsScreen()));
                    },
                    child: const Text("See All", style: TextStyle(color: AppColors.primaryGreen)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Nearby Request Card
              GestureDetector(
                onTap: () => _openRequest(featured),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AppNetworkImage(
                          featured.imageUrl,
                          width: 80,
                          height: 80,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              featured.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              featured.org,
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            // Real status badge for the featured request.
                            StatusBadge(featured.status, fontSize: 10),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _openRequest(featured),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          elevation: 0,
                        ),
                        child: const Text("View", style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DonateFoodScreen()));
        },
        backgroundColor: AppColors.primaryGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.assignment_outlined, "Requests", 1),
              const SizedBox(width: 40), // FAB Space
              _buildNavItem(Icons.volunteer_activism_outlined, "Donations", 2),
              _buildNavItem(Icons.person_outlined, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkStep(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xffF1F8E9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NearbyRequestsScreen()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyDonationsScreen()));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.primaryGreen : Colors.grey, size: 24),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primaryGreen : Colors.grey,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
