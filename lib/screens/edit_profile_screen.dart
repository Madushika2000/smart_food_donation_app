import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Edit Profile screen.
///
/// It receives the user's current details, shows them inside text fields,
/// and when "Save Changes" is tapped it sends the new details back to the
/// Profile screen using Navigator.pop. No Firebase / backend yet.
class EditProfileScreen extends StatefulWidget {
  // The current details, passed in from the Profile screen.
  final String name;
  final String email;
  final String phone;
  final String location;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // A controller connects each text field to the text the user types.
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController locationController;

  @override
  void initState() {
    super.initState();
    // Pre-fill each field with the current details.
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phone);
    locationController = TextEditingController(text: widget.location);
  }

  @override
  void dispose() {
    // Always clean up controllers to avoid memory leaks.
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }

  /// Reads the text fields and sends the new details back to the
  /// Profile screen. Closes this screen.
  void _saveChanges() {
    final String name = nameController.text.trim();

    // Simple check: the name should not be empty.
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name")),
      );
      return;
    }

    // Return the updated details to the previous screen.
    Navigator.pop(context, {
      'name': name,
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'location': locationController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery makes the layout responsive.
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidePadding = screenWidth * 0.05;
    final double avatarRadius = screenWidth * 0.13;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 10),
        child: Column(
          children: [
            // Avatar placeholder with a small camera badge (UI only).
            Stack(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: AppColors.lightGreen,
                  child: Icon(
                    Icons.person,
                    size: avatarRadius,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Input fields, pre-filled with the current details.
            _buildTextField(
              label: "Full Name",
              controller: nameController,
              icon: Icons.person_outline,
            ),
            _buildTextField(
              label: "Email",
              controller: emailController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              label: "Phone",
              controller: phoneController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              label: "Address",
              controller: locationController,
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 30),

            // Save button (green, full width).
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A reusable rounded text field with a label and a leading icon.
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primaryGreen),
          filled: true,
          fillColor: Colors.grey.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          ),
        ),
      ),
    );
  }
}
