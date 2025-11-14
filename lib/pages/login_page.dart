import 'package:flutter/material.dart';
import '/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String selectedRole = "customer";

  // ===================== VALIDATION =====================
  bool validateInputs() {
    if (emailController.text.trim().isEmpty ||
        !emailController.text.contains("@")) {
      showMessage("Enter valid email");
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      showMessage("Enter password");
      return false;
    }

    return true;
  }

  void showMessage(String msg, {Color color = Colors.redAccent}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ===================== LOGIN ACTION =====================
  Future<void> handleLogin() async {
    if (!validateInputs()) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiService.loginUser(
        emailController.text.trim(),
        passwordController.text.trim(),
        selectedRole,
      );

      setState(() => isLoading = false);

      if (response != null && response['message'] == 'Login successful') {
        final userId = response['user_id'];

        showMessage("Login Successful", color: Colors.green);

        if (response['role'] == 'owner') {
          Navigator.pushReplacementNamed(
            context,
            "/owner",
            arguments: {"userId": userId},
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            "/customer",
            arguments: {"userId": userId},
          );
        }
      } else {
        showMessage("Invalid credentials! Please try again.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      showMessage("Something went wrong. Try again!");
    }
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2dbd6e), Color(0xFFa6f77b)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: isMobile ? double.infinity : 360,
              decoration: BoxDecoration(
                color: const Color(0xFFfbfbfb),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(1, 3),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ------------------- TITLE -------------------
                    const SizedBox(height: 10),
                    const Text(
                      "LOGIN",
                      style: TextStyle(
                        letterSpacing: 4,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Raleway",
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 90,
                      height: 2,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFa6f77b), Color(0xFF2ec06f)],
                        ),
                      ),
                    ),

                    // ------------------- EMAIL -------------------
                    buildLabel("Email"),
                    buildInput(emailController,
                        type: TextInputType.emailAddress),

                    // ------------------- PASSWORD -------------------
                    buildLabel("Password", top: 20),
                    buildInput(passwordController, isPassword: true),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF2dbd6e),
                          ),
                        ),
                      ),
                    ),

                    // ------------------- ROLE DROPDOWN -------------------
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: selectedRole,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                  value: "owner", child: Text("Owner")),
                              DropdownMenuItem(
                                  value: "customer", child: Text("Customer")),
                            ],
                            onChanged: (value) {
                              setState(() => selectedRole = value!);
                            },
                          ),
                        ),
                      ),
                    ),

                    // ------------------- LOGIN BUTTON -------------------
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: isLoading ? null : handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2dbd6e),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 60 : 80,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF24c64f),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "LOGIN",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Raleway SemiBold",
                              ),
                            ),
                    ),

                    // ------------------- SIGNUP -------------------
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/register");
                      },
                      child: const Text(
                        "Don't have an account yet?",
                        style: TextStyle(
                          color: Color(0xFF2dbd6e),
                          fontSize: 10,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===================== UI HELPERS =====================
  Widget buildLabel(String text, {double top = 13}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(top: top),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontFamily: "Raleway"),
        ),
      ),
    );
  }

  Widget buildInput(TextEditingController controller,
      {bool isPassword = false, TextInputType type = TextInputType.text}) {
    return Column(
      children: [
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: type,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFa6f77b), Color(0xFF2ec06f)],
            ),
          ),
        ),
      ],
    );
  }
}
