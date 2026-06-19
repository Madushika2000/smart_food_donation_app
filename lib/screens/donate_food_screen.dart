import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../models/donation.dart';
import '../utils/donation_store.dart';
import 'my_donations_screen.dart';

/// Donate Food screen.
///
/// This is now a REAL, working form (not just UI):
///  - the category dropdown actually changes when you pick a value
///  - the text fields capture what you type (using controllers)
///  - the "+" button lets you add preset food photos
///  - the pickup date & time open real pickers and show your choice
///  - "Submit Donation" validates the form, creates a [Donation],
///    saves it to [DonationStore] and opens the My Donations screen.
///
/// It is a StatefulWidget because a form needs to remember the values the
/// user has entered/selected (its "state") and rebuild when they change.
class DonateFoodScreen extends StatefulWidget {
  const DonateFoodScreen({super.key});

  @override
  State<DonateFoodScreen> createState() => _DonateFoodScreenState();
}

class _DonateFoodScreenState extends State<DonateFoodScreen> {
  // Controllers let us read whatever the user typed in each text field.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // The list of categories shown in the dropdown.
  final List<String> _categories = const [
    "Cooked Meal",
    "Bakery Items",
    "Fruits & Vegetables",
    "Packaged Food",
    "Beverages",
    "Other",
  ];
  // The currently selected category (null until the user picks one).
  String? _selectedCategory;

  // Preset food photos the user can choose from (no camera plugin needed).
  final List<String> _presetImages = const [
    "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200",
    "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200",
    "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=200",
    "https://images.unsplash.com/photo-1519996529931-28324d5a630e?w=200",
    "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200",
    "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=200",
  ];
  // The photos the user has added to THIS donation.
  final List<String> _selectedImages = [];

  // The pickup date & time the user picks (null until chosen).
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;

  @override
  void dispose() {
    // Always free controllers when the screen is removed (avoids leaks).
    _titleController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "Donate Food",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step indicator (visual only — shows the donation has 3 parts).
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              child: Row(
                children: [
                  _buildStep(1, "Food Details", true),
                  _buildDivider(),
                  _buildStep(2, "Pickup Details", true),
                  _buildDivider(),
                  _buildStep(3, "Submit", false),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Food Information",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // ----- Food Category (real dropdown) -----
                    _buildLabel("Food Category"),
                    _buildDropdown(),
                    const SizedBox(height: 20),

                    // ----- Food Title -----
                    _buildLabel("Food Title"),
                    _buildTextField(_titleController, "E.g. Vegetable Rice"),
                    const SizedBox(height: 20),

                    // ----- Quantity -----
                    _buildLabel("Quantity"),
                    _buildTextField(_quantityController, "E.g. 10 Packets"),
                    const SizedBox(height: 20),

                    // ----- Description -----
                    _buildLabel("Food Description"),
                    _buildTextField(
                      _descriptionController,
                      "Describe the food details...",
                      maxLines: 4,
                    ),
                    const SizedBox(height: 30),

                    // ----- Food Images -----
                    const Text(
                      "Food Images",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildAddImageButton(),
                        // Show every photo the user has added so far.
                        ..._selectedImages.map(_buildSelectedThumbnail),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // ----- Pickup Details -----
                    const Text(
                      "Pickup Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Pickup Location"),
                    _buildTextField(_locationController, "Colombo, Sri Lanka"),
                    const SizedBox(height: 20),

                    _buildLabel("Pickup Date"),
                    _buildPickerTile(
                      text: _pickupDate == null
                          ? "Select pickup date"
                          : _formatDate(_pickupDate!),
                      icon: Icons.calendar_today_outlined,
                      hasValue: _pickupDate != null,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Pickup Time"),
                    _buildPickerTile(
                      text: _pickupTime == null
                          ? "Select pickup time"
                          : _formatTime(_pickupTime!),
                      icon: Icons.access_time,
                      hasValue: _pickupTime != null,
                      onTap: _pickTime,
                    ),
                    const SizedBox(height: 40),

                    // ----- Submit -----
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitDonation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Submit Donation",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTIONS (the "real" logic)
  // ---------------------------------------------------------------------------

  /// Opens a bottom sheet of preset food photos. Tapping one adds it.
  void _openImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose a food photo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: _presetImages.map((url) {
                  return GestureDetector(
                    onTap: () {
                      // Add the photo (if not already added) and close the sheet.
                      setState(() {
                        if (!_selectedImages.contains(url)) {
                          _selectedImages.add(url);
                        }
                      });
                      Navigator.pop(sheetContext);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(url, fit: BoxFit.cover),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Opens the built-in date picker and stores the chosen date.
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 6, 19),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _pickupDate = picked);
    }
  }

  /// Opens the built-in time picker and stores the chosen time.
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _pickupTime = picked);
    }
  }

  /// Validates the form, creates a [Donation], saves it and opens My Donations.
  void _submitDonation() {
    // Simple validation: the most important fields must be filled.
    if (_selectedCategory == null ||
        _titleController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty ||
        _pickupDate == null ||
        _pickupTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please add category, title, quantity, pickup date and time.",
          ),
        ),
      );
      return;
    }

    // Build the "Pickup: ..." line shown on the My Donations card.
    final String dateText =
        "Pickup: ${_formatDate(_pickupDate!)}, ${_formatTime(_pickupTime!)}";

    final Donation donation = Donation(
      title: _titleController.text.trim(),
      category: _selectedCategory!,
      quantity: _quantityController.text.trim(),
      description: _descriptionController.text.trim(),
      pickupLocation: _locationController.text.trim().isEmpty
          ? "Not specified"
          : _locationController.text.trim(),
      dateText: dateText,
      // Use the first added photo, or a default if the user added none.
      imageUrl: _selectedImages.isNotEmpty
          ? _selectedImages.first
          : "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200",
    );

    // Save it to the shared in-memory list.
    DonationStore.add(donation);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${donation.title}" added to My Donations!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );

    // Open My Donations so the user can immediately see the new item.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyDonationsScreen()),
    );
  }

  // ---------------------------------------------------------------------------
  // SMALL HELPERS
  // ---------------------------------------------------------------------------

  /// Formats a date like "19 Jun 2026" without needing extra packages.
  String _formatDate(DateTime d) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }

  /// Formats a time like "03:00 PM".
  String _formatTime(TimeOfDay t) {
    final int hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final String minute = t.minute.toString().padLeft(2, '0');
    final String period = t.period == DayPeriod.am ? "AM" : "PM";
    return "${hour.toString().padLeft(2, '0')}:$minute $period";
  }

  // ---------------------------------------------------------------------------
  // UI BUILDING BLOCKS
  // ---------------------------------------------------------------------------

  Widget _buildStep(int number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGreen : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primaryGreen : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Expanded(
      child: Container(
        height: 1,
        color: Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 14),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  /// Real dropdown. Picking a value updates [_selectedCategory] via setState.
  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xffF5F7FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCategory,
          hint: const Text(
            "Select category",
            style: TextStyle(color: Colors.grey),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          borderRadius: BorderRadius.circular(15),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (value) => setState(() => _selectedCategory = value),
        ),
      ),
    );
  }

  /// Reusable text field. Pass a [controller] so we can read its text later.
  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: const Color(0xffF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }

  /// The "+" button that opens the photo picker.
  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _openImagePicker,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.camera_alt_outlined,
            color: AppColors.primaryGreen),
      ),
    );
  }

  /// A chosen photo with a small "x" to remove it.
  Widget _buildSelectedThumbnail(String url) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(url, width: 70, height: 70, fit: BoxFit.cover),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => setState(() => _selectedImages.remove(url)),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// A tappable field for the date / time pickers.
  Widget _buildPickerTile({
    required String text,
    required IconData icon,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xffF5F7FA),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: hasValue ? Colors.black87 : Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
