import 'package:flutter/material.dart';
import '/services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedRole = "customer";
  bool isLoading = false;

  // ----------- Validation Error Messages -----------
  String usernameError = "";
  String emailError = "";
  String phoneError = "";
  String passwordError = "";

  bool validateInputs() {
    bool isValid = true;

    setState(() {
      usernameError = "";
      emailError = "";
      phoneError = "";
      passwordError = "";

      if (usernameController.text.trim().isEmpty) {
        usernameError = "Username required";
        isValid = false;
      }
      if (emailController.text.trim().isEmpty ||
          !emailController.text.contains("@")) {
        emailError = "Enter valid email";
        isValid = false;
      }
      // Assuming phone number is numeric and at least 10 digits
      if (phoneController.text.trim().isEmpty ||
          phoneController.text.length < 10 ||
          !RegExp(r'^\d+$').hasMatch(phoneController.text.trim())) {
        phoneError = "Enter valid phone (at least 10 digits)";
        isValid = false;
      }
      if (passwordController.text.trim().length < 4) {
        passwordError = "Password must be at least 4 characters";
        isValid = false;
      }
    });

    return isValid;
  }

  // ---------------- API CALL (FIXED NAVIGATION LOGIC) -------------------
  Future<void> handleRegister() async {
    if (!validateInputs()) return;

    setState(() => isLoading = true);

    final response = await ApiService.registerUser({
      "username": usernameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "phone_number": phoneController.text.trim(),
      "role": selectedRole,
    });

    // Stop loading indicator immediately after response is received
    setState(() => isLoading = false);

    // IF API returns ANY valid response → treat it as SUCCESS
    if (response != null) {

      // Show SUCCESS SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registered successfully! Please login."),
          backgroundColor: Colors.green,
        ),
      );

      // Wait for a short duration to let the user see the SnackBar
      await Future.delayed(const Duration(milliseconds: 700));

      // 🚀 CRITICAL CHECK: Ensure widget is still mounted before navigation
      if (!mounted) return;

      // Navigate to the login page ('/') and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
      return;
    }

    // FAIL CASE
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Registration failed! Try again."),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2dbd6e), Color(0xFFa6f77b)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: isMobile ? 330 : 360,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  // Title
                  const Text(
                    "REGISTER",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Color(0xFF2dbd6e)
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ================= FORM =================

                  buildField(
                    label: "Username",
                    controller: usernameController,
                    error: usernameError,
                    icon: Icons.person_outline,
                  ),

                  buildField(
                    label: "Email",
                    controller: emailController,
                    error: emailError,
                    type: TextInputType.emailAddress,
                    icon: Icons.email_outlined,
                  ),

                  buildField(
                    label: "Phone Number",
                    controller: phoneController,
                    error: phoneError,
                    type: TextInputType.phone,
                    icon: Icons.phone_outlined,
                  ),

                  buildField(
                    label: "Password",
                    controller: passwordController,
                    error: passwordError,
                    isPassword: true,
                    icon: Icons.lock_outline,
                  ),

                  const SizedBox(height: 10),

                  // Role dropdown
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          items: const [
                            DropdownMenuItem(
                                value: "owner", child: Text("Shop Owner")),
                            DropdownMenuItem(
                                value: "customer", child: Text("Customer")),
                          ],
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() => selectedRole = value);
                            }
                          },
                          isExpanded: true,
                          style: TextStyle(color: Colors.grey[800], fontSize: 14),
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2dbd6e)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Register Button
                  ElevatedButton(
                    onPressed: isLoading ? null : handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2dbd6e),
                      disabledBackgroundColor: const Color(0xFFa6f77b),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                      elevation: 5,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "REGISTER",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                            ),
                          ),
                  ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/");
                    },
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        color: Color(0xFF2dbd6e),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----------- FIELD WIDGET WITH INLINE VALIDATION -----------
  Widget buildField({
    required String label,
    required TextEditingController controller,
    required String error,
    IconData? icon,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
          TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: type,
            cursorColor: const Color(0xFF2dbd6e),
            decoration: InputDecoration(
              prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF2dbd6e), size: 18) : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 35),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2dbd6e)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2dbd6e), width: 2),
              ),
            ),
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}