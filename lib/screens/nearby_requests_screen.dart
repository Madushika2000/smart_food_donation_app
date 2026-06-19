import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'request_details_screen.dart';

/// Nearby Requests screen.
///
/// Layout (top to bottom):
///   - Top bar: back button, "Nearby Requests" title, filter icon
///   - Search bar
///   - A map placeholder (light background) with green location pins
///   - A white rounded sheet overlaying the bottom 40% of the map,
///     holding a scrollable list of Request Cards.
///
/// UI only (no real map plugin yet). The "View" button opens the
/// Request Details page; the back button returns to the Home dashboard.
class NearbyRequestsScreen extends StatelessWidget {
  const NearbyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Height of the white overlay sheet = bottom 40% of the screen.
    final double sheetHeight = MediaQuery.of(context).size.height * 0.40;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          // Returns to the Home dashboard (the screen that opened this one).
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Nearby Requests",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Filter / settings icon on the right.
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ----- SEARCH BAR -----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by area or organization",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xffF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // ----- MAP + OVERLAY LIST -----
          Expanded(
            child: Stack(
              children: [
                // Map placeholder fills the whole area behind the sheet.
                Positioned.fill(child: _buildMapPlaceholder()),

                // White rounded sheet overlaying the bottom 40%.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: sheetHeight,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Small drag handle for a clean, modern look.
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Scrollable list of request cards.
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            children: [
                              _buildRequestItem(
                                context,
                                "Meals for 20 People",
                                "by Charity Hub",
                                "0.5 km away",
                                "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=200",
                              ),
                              const SizedBox(height: 15),
                              _buildRequestItem(
                                context,
                                "Food Packets Needed",
                                "by Care Center",
                                "1.2 km away",
                                "https://images.unsplash.com/photo-1593113598332-cd288d649433?w=200",
                              ),
                              const SizedBox(height: 15),
                              _buildRequestItem(
                                context,
                                "Help for Shelter Home",
                                "by Helping Hands",
                                "1.8 km away",
                                "https://images.unsplash.com/photo-1547573854-74d2a71d0827?w=200",
                              ),
                              const SizedBox(height: 15),
                              _buildRequestItem(
                                context,
                                "Bakery Items for Kids",
                                "by Smile Foundation",
                                "2.3 km away",
                                "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A simple "map" background: a soft coloured area with a faint map icon
  /// and several green location pins scattered around (UI placeholder).
  Widget _buildMapPlaceholder() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;
        return Container(
          color: const Color(0xffEAEFEA), // soft map-like grey/green
          child: Stack(
            children: [
              // Faint base map icon in the middle.
              Center(
                child: Icon(
                  Icons.map_outlined,
                  size: 120,
                  color: Colors.grey.withValues(alpha: 0.25),
                ),
              ),
              // Green pins kept in the TOP half so the bottom sheet
              // (40% of the screen) does not cover them.
              Positioned(left: w * 0.12, top: h * 0.08, child: _buildMapPin(34)),
              Positioned(left: w * 0.55, top: h * 0.05, child: _buildMapPin(28)),
              Positioned(left: w * 0.78, top: h * 0.16, child: _buildMapPin(40)),
              Positioned(left: w * 0.30, top: h * 0.22, child: _buildMapPin(30)),
              Positioned(left: w * 0.64, top: h * 0.30, child: _buildMapPin(26)),
              Positioned(left: w * 0.16, top: h * 0.34, child: _buildMapPin(32)),
            ],
          ),
        );
      },
    );
  }

  /// A single green location pin used on the map placeholder.
  Widget _buildMapPin(double size) {
    return Icon(
      Icons.location_on,
      color: AppColors.primaryGreen,
      size: size,
      // A subtle shadow so the pin stands out from the map background.
      shadows: const [
        Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
      ],
    );
  }

  /// A single request card: thumbnail, title, organization, distance, View.
  Widget _buildRequestItem(
    BuildContext context,
    String title,
    String org,
    String distance,
    String imageUrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Rounded thumbnail image on the left.
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          // Title + organization + distance.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(org,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.grey),
                    Text(" $distance",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          // Green "View" button → opens the Request Details page.
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RequestDetailsScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              elevation: 0,
            ),
            child: const Text("View",
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
