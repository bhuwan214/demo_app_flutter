import 'package:flutter/material.dart';
import "dart:convert";
import 'package:http/http.dart' as http;
import 'dart:async';
import 'widget/opt_verify.dart';

class SignupPage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SignupPage({
    Key? key,
    required this.themeMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signupUser() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        mobile.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    const String url =
        "https://ecommerce.atithyahms.com/api/v2/ecommerce/customer/register";

    try {
      final requestBody = {
        'first_name': firstName,
        'last_name': lastName,
        'mobile_no': mobile,
        'password': password,
        'device_token':
            'eEcu_X4XMkspr7fsv6IlrL:APA91bFcUP60TtS7Nf-WMBhpxhFbXLuzYvVmo6e7Iczct6oNH3XUFrM1k0J2sr5pkQ-RGbF7Sssf7JWY5CZnEiApFnq5lvj4MajFpKZ7aqr32Jzxn1IR6W_zoJO7-vl-163q3xnEQ9QS',
      };
      
      // print('Request Body: $requestBody');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      // Check if response is JSON before decoding
      if (response.body.trim().startsWith('<')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server error. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final data = jsonDecode(response.body);
      print('Parsed data: $data');
      print('Status field: ${data['status']}');
      print('Success field: ${data['success']}');
      print('Message field: ${data['message']}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 203) {
        // Check multiple possible success indicators
        final isSuccess = data['status'] == true || 
                          data['success'] == true ||
                          data['status'] == 1 ||
                          response.statusCode == 201;
        // print('isSuccess: $isSuccess');


        if (isSuccess) {
          if (!mounted) return;
          
          // Show OTP verification dialog
          _showOtpDialog(mobile, firstName, lastName);
        } else {
          if (!mounted) return;
          // Get error message from various possible fields
          String errorMsg = data['message'] ?? 
                           data['error'] ?? 
                           data['errors']?.toString() ?? 
                           'Registration failed. Please check your details and try again.';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
          print('Full error data: $data');
        }
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Mobile number already registered'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = "Invalid request. Please check your input.";
            break;
          case 500:
            errorMessage = "Server error. Please try again later.";
            break;
          default:
            errorMessage = data['message'] ?? "Sign up failed. Please try again.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Signup Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error. Please check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOtpDialog(String mobile, String firstName, String lastName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return OtpVerificationDialog(
          mobileNumber: mobile,
          firstName: firstName,
          lastName: lastName,
        );
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = widget.themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/toonbackdrop.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            isDarkMode
                ? Colors.black.withOpacity(0.6)
                : Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
          onError: (exception, stackTrace) {
            debugPrint('Failed to load background image: $exception');
          },
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Login Form
            SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    // Top Bar with Welcome and Theme Toggle
                    SignupTopBar(
                      isDarkMode: isDarkMode,
                      colorScheme: colorScheme,
                      widget: widget,
                    ),

                    const SizedBox(height: 40),

                    // Signup Form
                    Form(
                      key: _formKey,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 35),
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // First Name Field
                            TextFormField(
                              controller: _firstNameController,
                              style: TextStyle(color: colorScheme.onSurface),
                              decoration: InputDecoration(
                                fillColor: isDarkMode
                                    ? colorScheme.surface
                                    : Colors.grey[100],
                                filled: true,
                                hintText: 'First Name',
                                hintStyle: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: colorScheme.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.outline.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Last Name Field
                            TextFormField(
                              controller: _lastNameController,
                              style: TextStyle(color: colorScheme.onSurface),
                              decoration: InputDecoration(
                                fillColor: isDarkMode
                                    ? colorScheme.surface
                                    : Colors.grey[100],
                                filled: true,
                                hintText: 'Last Name',
                                hintStyle: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: colorScheme.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.outline.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Mobile Field
                            TextFormField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(color: colorScheme.onSurface),
                              decoration: InputDecoration(
                                fillColor: isDarkMode
                                    ? colorScheme.surface
                                    : Colors.grey[100],
                                filled: true,
                                hintText: 'Mobile Number',
                                hintStyle: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  color: colorScheme.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.outline.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              style: TextStyle(color: colorScheme.onSurface),
                              decoration: InputDecoration(
                                fillColor: isDarkMode
                                    ? colorScheme.surface
                                    : Colors.grey[100],
                                filled: true,
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: colorScheme.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.outline.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signupUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: colorScheme.onPrimary,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Already have account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Top Bar Widget for Signup
class SignupTopBar extends StatelessWidget {
  const SignupTopBar({
    super.key,
    required this.isDarkMode,
    required this.colorScheme,
    required this.widget,
  });

  final bool isDarkMode;
  final ColorScheme colorScheme;
  final SignupPage widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 35, top: 75, right: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Welcome',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.white,
              fontSize: 33,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
          // Theme Toggle Button
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                // Toggle theme
                widget.onThemeChanged(
                  isDarkMode ? ThemeMode.light : ThemeMode.dark,
                );
              },
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: colorScheme.primary,
              ),
              tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
            ),
          ),
        ],
      ),
    );
  }
}

