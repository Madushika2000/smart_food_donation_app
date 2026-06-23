import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/food_request.dart';
import '../utils/colors.dart';
import '../utils/request_store.dart';
import '../widgets/app_network_image.dart';
import '../widgets/status_badge.dart';
import 'request_details_screen.dart';

/// Nearby Requests screen.
///
/// A real, interactive OpenStreetMap (via the flutter_map plugin) shows:
///   - the user's live GPS location (blue dot),
///   - each food request (green pin),
///   - a searched place (red pin) when the user searches an area.
///
/// The search box geocodes a place name (e.g. "Kandy") with OpenStreetMap's
/// free Nominatim service and flies the map there. The request list below
/// shows the real distance to each request, nearest first.
class NearbyRequestsScreen extends StatefulWidget {
  const NearbyRequestsScreen({super.key});

  @override
  State<NearbyRequestsScreen> createState() => _NearbyRequestsScreenState();
}

class _NearbyRequestsScreenState extends State<NearbyRequestsScreen> {
  /// Where the map starts before we know the user's location (Colombo).
  static const LatLng _defaultCenter = LatLng(6.9271, 79.8612);

  /// Controls the map so we can fly it to the user / searched location.
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  /// The device's last known GPS position (null until we get a fix).
  Position? _myPosition;

  /// A place the user searched for (null until they search). Drawn as a red pin.
  LatLng? _searchedPoint;

  /// True while we are reading GPS / running a search (for spinners).
  bool _loading = false;
  bool _searching = false;

  /// A short, user-facing message when we cannot get a GPS location
  /// (services off, permission denied, etc.). Null when all is well.
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    // Try to get the user's location as soon as the screen opens.
    _locateMe();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Reads the device's current GPS position, requesting permission if
  /// needed, then flies the map to it.
  Future<void> _locateMe() async {
    setState(() {
      _loading = true;
      _statusMessage = null;
    });

    try {
      // 1) Is the device's location service (GPS) switched on at all?
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _finishWithMessage(
          "Location is turned off. Switch on GPS and tap the locate button.",
        );
        return;
      }

      // 2) Has the user granted this app permission to use the location?
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _finishWithMessage(
            "Location permission denied. Allow access to see nearby requests.",
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _finishWithMessage(
          "Location permission is permanently denied. Enable it in Settings.",
        );
        return;
      }

      // 3) Permission granted — get a fresh, high-accuracy fix.
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!mounted) return;
      setState(() {
        _myPosition = position;
        _loading = false;
      });
      _moveMap(LatLng(position.latitude, position.longitude), 14);
    } catch (e) {
      _finishWithMessage("Could not get your location. Please try again.");
    }
  }

  /// Geocodes [rawQuery] (e.g. "Kandy") using OpenStreetMap's free Nominatim
  /// service, then flies the map to the result and drops a red pin.
  Future<void> _searchPlace(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus(); // hide the keyboard
    setState(() => _searching = true);

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'json',
        'limit': '1',
      });
      // Nominatim requires a descriptive User-Agent identifying the app.
      final response = await http.get(uri, headers: {
        'User-Agent': 'smart_food_donation_app/1.0 (flutter demo)',
      });

      if (!mounted) return;

      if (response.statusCode != 200) {
        _showSnack("Search failed (${response.statusCode}). Try again.");
        setState(() => _searching = false);
        return;
      }

      final List<dynamic> results = jsonDecode(response.body) as List<dynamic>;
      if (results.isEmpty) {
        _showSnack('No place found for "$query".');
        setState(() => _searching = false);
        return;
      }

      final first = results.first as Map<String, dynamic>;
      final point = LatLng(
        double.parse(first['lat'] as String),
        double.parse(first['lon'] as String),
      );

      setState(() {
        _searchedPoint = point;
        _searching = false;
      });
      _moveMap(point, 13);
    } catch (e) {
      if (!mounted) return;
      _showSnack("Could not search right now. Check your connection.");
      setState(() => _searching = false);
    }
  }

  /// Safely moves the map (ignored if the map is not ready yet).
  void _moveMap(LatLng point, double zoom) {
    try {
      _mapController.move(point, zoom);
    } catch (_) {
      // Map controller not attached yet — safe to ignore.
    }
  }

  /// Helper: stop loading and show a GPS status message (guards against the
  /// widget having been disposed during the async work).
  void _finishWithMessage(String message) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _statusMessage = message;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Distance in kilometres from the user to [r], or null if no GPS yet.
  double? _distanceKm(FoodRequest r) {
    final pos = _myPosition;
    if (pos == null) return null;
    final meters =
        Geolocator.distanceBetween(pos.latitude, pos.longitude, r.lat, r.lng);
    return meters / 1000;
  }

  /// Requests sorted nearest-first once we know where the user is.
  List<FoodRequest> get _sortedRequests {
    if (_myPosition == null) return RequestStore.all;
    final list = List<FoodRequest>.from(RequestStore.all);
    list.sort((a, b) => _distanceKm(a)!.compareTo(_distanceKm(b)!));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    // Height of the white overlay sheet = bottom 38% of the screen.
    final double sheetHeight = MediaQuery.of(context).size.height * 0.38;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Nearby Requests",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Locate-me icon: re-reads GPS and flies the map to the user.
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.black),
            tooltip: "Use my location",
            onPressed: _loading ? null : _locateMe,
          ),
        ],
      ),
      body: Column(
        children: [
          // ----- SEARCH BAR (geocodes a place and moves the map) -----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _searchPlace,
              decoration: InputDecoration(
                hintText: "Search a place (e.g. Kandy)",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                // Tap-to-search button (or a spinner while searching).
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.arrow_forward,
                            color: AppColors.primaryGreen),
                        onPressed: () => _searchPlace(_searchController.text),
                      ),
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

          // ----- LIVE LOCATION BANNER -----
          _buildLocationBanner(),

          // ----- REAL MAP + OVERLAY LIST -----
          Expanded(
            child: Stack(
              children: [
                // The real, interactive OpenStreetMap fills the area.
                Positioned.fill(child: _buildMap()),

                // OpenStreetMap attribution (required by their tile policy).
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: Colors.white70,
                    child: const Text(
                      "© OpenStreetMap",
                      style: TextStyle(fontSize: 9, color: Colors.black54),
                    ),
                  ),
                ),

                // White rounded sheet overlaying the bottom of the map.
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
                        // Scrollable list of request cards (nearest first).
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            itemCount: _sortedRequests.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 15),
                            itemBuilder: (context, index) {
                              final r = _sortedRequests[index];
                              return _buildRequestItem(context, r);
                            },
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

  /// The real OpenStreetMap with tile layer and all markers.
  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: 12,
        minZoom: 3,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.smart_food_donation_app',
        ),
        MarkerLayer(markers: _buildMarkers()),
      ],
    );
  }

  /// Builds the map markers: green request pins, an optional red searched
  /// pin, and a blue dot for the user's live location.
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Green pins for every request. Tapping one centres the map on it.
    for (final r in RequestStore.all) {
      markers.add(
        Marker(
          point: LatLng(r.lat, r.lng),
          width: 40,
          height: 40,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () => _moveMap(LatLng(r.lat, r.lng), 15),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primaryGreen,
              size: 40,
              shadows: [
                Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
          ),
        ),
      );
    }

    // Red pin for a searched place (e.g. "Kandy").
    if (_searchedPoint != null) {
      markers.add(
        Marker(
          point: _searchedPoint!,
          width: 44,
          height: 44,
          alignment: Alignment.topCenter,
          child: const Icon(
            Icons.location_on,
            color: Colors.redAccent,
            size: 44,
            shadows: [
              Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
        ),
      );
    }

    // Blue dot for the user's live GPS location.
    if (_myPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_myPosition!.latitude, _myPosition!.longitude),
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 4),
              ],
            ),
          ),
        ),
      );
    }

    return markers;
  }

  /// A thin banner under the search bar that reflects the GPS state:
  /// loading, a status/permission message (with retry), or the live
  /// coordinates once we have a fix.
  Widget _buildLocationBanner() {
    Widget child;
    Color background = const Color(0xffEAF6EE); // soft green

    if (_loading) {
      child = Row(
        children: const [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text("Getting your location…",
              style: TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      );
    } else if (_statusMessage != null) {
      background = const Color(0xffFDECEC); // soft red
      child = Row(
        children: [
          const Icon(Icons.location_off, size: 18, color: Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage!,
              style: const TextStyle(fontSize: 12.5, color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: _locateMe,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text("Retry"),
          ),
        ],
      );
    } else if (_myPosition != null) {
      final pos = _myPosition!;
      child = Row(
        children: [
          const Icon(Icons.my_location, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "You are here  •  "
              "${pos.latitude.toStringAsFixed(4)}, "
              "${pos.longitude.toStringAsFixed(4)}",
              style: const TextStyle(fontSize: 12.5, color: Colors.black87),
            ),
          ),
        ],
      );
    } else {
      child = Row(
        children: [
          const Icon(Icons.location_searching, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          const Expanded(
            child: Text("Tap the locate button to find requests near you.",
                style: TextStyle(fontSize: 12.5, color: Colors.black87)),
          ),
          TextButton(
            onPressed: _locateMe,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text("Locate"),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  /// A single request card: thumbnail, title, organization, status, distance.
  /// Tapping the card (outside the View button) centres the map on it.
  Widget _buildRequestItem(BuildContext context, FoodRequest r) {
    final double? km = _distanceKm(r);
    final String distanceLabel = km == null
        ? "Distance unavailable"
        : "${km.toStringAsFixed(1)} km away";

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => _moveMap(LatLng(r.lat, r.lng), 15),
      child: Container(
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
              child: AppNetworkImage(r.imageUrl, width: 70, height: 70),
            ),
            const SizedBox(width: 15),
            // Title + organization + status + distance.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(r.org,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 6),
                  // Real status badge for this request.
                  StatusBadge(r.status, fontSize: 10),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey),
                      Text(" $distanceLabel",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            // Green "View" button → opens the Request Details page with this
            // request. Awaited so the list refreshes if its status changed.
            ElevatedButton(
              onPressed: () => _openDetails(r, distanceLabel),
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
      ),
    );
  }

  /// Opens the details page for [r], then refreshes so any status change made
  /// there is reflected in this list.
  Future<void> _openDetails(FoodRequest r, String? distanceLabel) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailsScreen(
          request: r,
          distanceLabel: distanceLabel,
        ),
      ),
    );
    if (mounted) setState(() {});
  }
}
