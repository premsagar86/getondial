import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final formKey = GlobalKey<FormState>();

    InputDecoration outlineInput(String hint, {IconData? prefixIcon}) {
      return InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.grey)
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Red Header with Logo
            Container(
              height: isDesktop ? 200 : screenHeight * 0.25,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Center(
                child: FlutterLogo(size: isDesktop ? 140 : screenWidth * 0.25),
              ),
            ),

            // Sign Up Form
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: isDesktop ? 600 : double.infinity,
                  padding: const EdgeInsets.all(24),
                  margin: isDesktop
                      ? const EdgeInsets.all(16)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Text(
                            "Create Account ✨",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Join us and start your journey",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // First + Last Name
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: outlineInput(
                                    "First Name",
                                    prefixIcon: Icons.person,
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? "Enter first name"
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  decoration: outlineInput(
                                    "Last Name",
                                    prefixIcon: Icons.person,
                                  ),
                                  validator: (value) =>
                                      value!.isEmpty ? "Enter last name" : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Email
                          TextFormField(
                            decoration: outlineInput(
                              "Email Address",
                              prefixIcon: Icons.email,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter email";
                              }
                              if (!RegExp(
                                r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                              ).hasMatch(value)) {
                                return "Enter valid email";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Mobile Number
                          const Text(
                            "Mobile Number",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "+91",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),

                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      hintText: "Enter your mobile number",
                                    ),
                                    validator: (value) => value!.isEmpty
                                        ? "Enter mobile number"
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Password
                          TextFormField(
                            obscureText: true,
                            decoration: outlineInput(
                              "Password",
                              prefixIcon: Icons.lock,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter password";
                              }
                              if (value.length < 6) {
                                return "Min 6 characters required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Confirm Password
                          TextFormField(
                            obscureText: true,
                            decoration: outlineInput(
                              "Confirm Password",
                              prefixIcon: Icons.lock,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Confirm password";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Referral Code
                          TextFormField(
                            decoration: outlineInput(
                              "Referral Code (Optional)",
                              prefixIcon: Icons.card_giftcard,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Terms Checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: false,
                                activeColor: Colors.red,
                                onChanged: (bool? value) {},
                              ),
                              const Expanded(
                                child: Text(
                                  "I accept the terms and conditions",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  // Handle sign up
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  "or continue with",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Social Login Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.facebook),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.g_mobiledata),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Already have an account
                          Center(
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Already have an account? Sign In",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
