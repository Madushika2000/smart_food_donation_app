import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/current_user.dart';
import '../widgets/app_network_image.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

/// Login screen.
///
/// Validates the entered credentials against the account created at signup
/// (stored locally via [CurrentUser]). It gives clear, distinct feedback:
///   - empty fields        → inline red error text under the field,
///   - wrong username/email → "Invalid username or email" (red SnackBar),
///   - wrong password       → "Incorrect password",
///   - both wrong           → "Invalid login credentials".
///
/// The Login button stays disabled until both fields have text. No Firebase /
/// backend yet — everything is checked locally.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Used to run the TextFormField validators (empty-field checks).
  final _formKey = GlobalKey<FormState>();

  // Controllers let us read the text the user types in each field.
  final TextEditingController identityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Hides/reveals the password text.
  bool _obscurePassword = true;

  // Whether both required fields have content (drives the button's enabled
  // state, so the user cannot submit an empty form).
  bool _fieldsFilled = false;

  @override
  void initState() {
    super.initState();
    // Re-check "are both fields filled?" whenever the user types.
    identityController.addListener(_updateFieldsFilled);
    passwordController.addListener(_updateFieldsFilled);
  }

  @override
  void dispose() {
    // Clean up controllers to avoid memory leaks.
    identityController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Enables the Login button only when both fields have text.
  void _updateFieldsFilled() {
    final filled = identityController.text.trim().isNotEmpty &&
        passwordController.text.isNotEmpty;
    if (filled != _fieldsFilled) {
      setState(() => _fieldsFilled = filled);
    }
  }

  /// Validates the form, checks the credentials, and either shows a clear
  /// error message or continues to the Home screen.
  Future<void> _login() async {
    // 1) Empty-field validation (inline red error text under each field).
    if (!_formKey.currentState!.validate()) return;

    final String identity = identityController.text.trim();
    final String password = passwordController.text;

    // 2) Check the credentials against the saved account.
    final LoginResult result = CurrentUser.validateLogin(identity, password);

    switch (result) {
      case LoginResult.noAccount:
        _showError("No account found. Please sign up first.");
        return;
      case LoginResult.wrongIdentity:
        _showError("Invalid username or email");
        return;
      case LoginResult.wrongPassword:
        _showError("Incorrect password");
        return;
      case LoginResult.wrongBoth:
        _showError("Invalid login credentials");
        return;
      case LoginResult.success:
        break; // fall through to navigation below
    }

    // 3) Success — the saved account is already the current user.
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
        settings: const RouteSettings(name: HomeScreen.routeName),
      ),
    );
  }

  /// Shows a user-friendly red error SnackBar.
  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            // Show empty-field errors as soon as the user starts interacting.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Login to continue",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                // Cartoon illustration (flat vector style, matches the theme).
                Center(
                  child: Image.asset(
                    "assets/images/splash_b.webp",
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F8E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.shopping_basket_rounded,
                        size: 100,
                        color: Color(0xff4CAF50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Username or Email field.
                _buildField(
                  label: "Username or Email",
                  hint: "Enter your username or email",
                  icon: Icons.person_outline,
                  controller: identityController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Username or email cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Password field.
                _buildField(
                  label: "Password",
                  hint: "Enter your password",
                  icon: Icons.lock_outline,
                  controller: passwordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password cannot be empty";
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                          color: Color(0xff4CAF50),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Login button — disabled until both fields are filled.
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _fieldsFilled ? _login : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color:
                            _fieldsFilled ? Colors.white : Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    "or continue with",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),
                // Social buttons.
                Row(
                  children: [
                    Expanded(
                      child: _socialButton(
                        "Google",
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png",
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _socialButton(
                        "Facebook",
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_%282019%29.png/1200px-Facebook_Logo_%282019%29.png",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Sign up link.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xff4CAF50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A labelled input that validates with the Form and shows red error text
  /// (and a red border) when invalid. For the password field it also adds a
  /// working show/hide toggle.
  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    OutlineInputBorder roundedBorder(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: width == 0
            ? BorderSide.none
            : BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            // Password show/hide toggle.
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xffF5F7FA),
            border: roundedBorder(Colors.transparent, 0),
            enabledBorder: roundedBorder(Colors.transparent, 0),
            focusedBorder: roundedBorder(AppColors.primaryGreen, 1.5),
            errorBorder: roundedBorder(Colors.red, 1.2),
            focusedErrorBorder: roundedBorder(Colors.red, 1.5),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _socialButton(String label, String logoUrl) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppNetworkImage(logoUrl, height: 20, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
