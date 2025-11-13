import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // 🧠 LOGIN FUNCTION
  Future<void> _loginUser() async {
    final username = _userNameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields')),
      );
      return;
    }

    const String url =
        'https://ecommerce.atithyahms.com/api/v2/ecommerce/customer/login';

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'device_token':
              "eyurwex5Rqy5Qvu8fz2OtV:APA91bF-C3fcf6sDkqccb2OqVt-5ADIk1rpPpAA81zJ4wQLjrmoglrvklmcSZPi2EkxvC7PjMtDPmDBaWpczQs2p4xDRfeo9aGov8_UiJxE5m70am8Fc9BEriJ8Z9_kwzpEgwe0ZnWBK",
        }),
      );

      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 203) && 
          (data['status'] == true || data['success'] == true)) {
        final userData = data['data'] ?? data['user'];
        final userName = userData?['first_name'] ?? userData?['name'] ?? 'User';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Successful! Welcome $userName'),
          ),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 35, top: 130),
            child: const Text(
              'Welcome\nBack',
              style: TextStyle(color: Colors.white, fontSize: 33),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 300),
                  Form(
                    key: _formKey,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 35),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _userNameController,
                            decoration: InputDecoration(
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              hintText: 'Username or Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xff4c505b),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : IconButton(
                                        color: Colors.white,
                                        onPressed: _loginUser,
                                        icon:
                                            const Icon(Icons.arrow_forward),
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 18,
                                    color: Color(0xff4c505b),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Feature coming soon'),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Forgot Password',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 18,
                                    color: Color(0xff4c505b),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}