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
  String selectedRole = 'customer';
  bool isLoading = false;

  Future<void> handleLogin() async {
    setState(() => isLoading = true);
    final response = await ApiService.loginUser(
      emailController.text.trim(),
      passwordController.text.trim(),
      selectedRole,
    );
    setState(() => isLoading = false);

    if (response != null && response['message'] == 'Login successful') {
      final userId = response['user_id'];
      if (response['role'] == 'owner') {
        Navigator.pushReplacementNamed(context, '/owner', arguments: {'userId': userId});
      } else if (response['role'] == 'customer') {
        Navigator.pushReplacementNamed(context, '/customer', arguments: {'userId': userId});
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed! Please check credentials.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xFF2dbd6e), Color(0xFFa6f77b)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: isMobile ? double.infinity : 360, // Responsive width
              margin: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: const Color(0xFFfbfbfb),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(1, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
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

                    // Email Field
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: 13),
                        child: Text(
                          "Email",
                          style: TextStyle(
                            fontFamily: "Raleway",
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
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

                    // Password Field
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: 22),
                        child: Text(
                          "Password",
                          style: TextStyle(
                            fontFamily: "Raleway",
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
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

                    // Forgot Password
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(
                            fontFamily: "Raleway",
                            fontSize: 10,
                            color: Color(0xFF2dbd6e),
                          ),
                        ),
                      ),
                    ),

                    // Role Dropdown
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
                              DropdownMenuItem(value: 'owner', child: Text("Owner")),
                              DropdownMenuItem(value: 'customer', child: Text("Customer")),
                            ],
                            onChanged: (val) => setState(() => selectedRole = val!),
                            icon: const Icon(Icons.arrow_drop_down),
                            isExpanded: true,
                          ),
                        ),
                      ),
                    ),

                    // Login Button
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2dbd6e),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 60 : 80,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21),
                        ),
                        shadowColor: const Color(0xFF24c64f),
                        elevation: 8,
                      ),
                      onPressed: isLoading ? null : handleLogin,
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
                                fontFamily: "Raleway SemiBold",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    // Signup
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Don't have an account yet?",
                        style: TextStyle(
                          color: Color(0xFF2dbd6e),
                          fontFamily: "Raleway",
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
}
