import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'core/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ProfilePage({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profileImage;

  String firstName = "";
  String lastName = "";
  String username = "";
  String phoneNumber = "";
  String email = "";

  bool _isLoading = true;

  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _lastController = TextEditingController();
  final TextEditingController _userController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImagePath = prefs.getString('profile_image_path');
    if (savedImagePath != null && File(savedImagePath).existsSync()) {
      setState(() {
        _profileImage = savedImagePath;
      });
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final userData = await AuthService.getUserData();

    if (userData != null) {
      firstName = userData["first_name"] ?? "";
      lastName = userData["last_name"] ?? "";
      username = userData["username"] ?? "";
      phoneNumber = userData["mobile_no"] ?? "";
      email = userData["email"] ?? "";

      _firstController.text = firstName;
      _lastController.text = lastName;
      _userController.text = username;
    }

    setState(() => _isLoading = false);
  }

  Future<void> updateProfile() async {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Saving..."),
        duration: Duration(seconds: 1),
      ),
    );

    final token = await AuthService.getToken();
    if (token == null) return;

    final url = Uri.parse(
      "https://ecommerce.atithyahms.com/api/ecommerce/customer/profile/edit",
    );

    final body = {
      "first_name": _firstController.text,
      "last_name": _lastController.text,
      "username": _userController.text,
      "email": email,
    };

    final response = await http.post(
      url,
      headers: {"Authorization": "Bearer $token"},
      body: body,
    );

    if (response.statusCode == 200) {
      setState(() {
        firstName = _firstController.text;
        lastName = _lastController.text;
        username = _userController.text;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: ${response.body}"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();

    // Show dialog to choose between gallery and camera
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? picked = await picker.pickImage(source: source);

      if (picked != null) {
        // Save the image path to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', picked.path);

        setState(() {
          _profileImage = picked.path;
        });
      }
    }
  }

  void _openEditPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Edit Profile",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // FIRST NAME
                TextField(
                  controller: _firstController,
                  decoration: const InputDecoration(
                    labelText: "First Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // LAST NAME
                TextField(
                  controller: _lastController,
                  decoration: const InputDecoration(
                    labelText: "Last Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // USERNAME
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: updateProfile,
              child: const Text("Save Changes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = widget.themeMode == ThemeMode.dark;

    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: Column(
                      children: [
                        // PROFILE PHOTO
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _profileImage != null
                                  ? FileImage(File(_profileImage!))
                                  : null,
                              child: _profileImage == null
                                  ? const Icon(Icons.person, size: 50)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 4,
                              child: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary,
                                radius: 18,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: _pickProfileImage,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Text(
                          "$firstName $lastName".trim().isNotEmpty
                              ? "$firstName $lastName".trim()
                              : "User",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (phoneNumber.isNotEmpty)
                          Text(
                            phoneNumber,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),

                        const SizedBox(height: 14),

                        ElevatedButton.icon(
                          onPressed: _openEditPopup,
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit Profile"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // ------------------------------
                  // OLD LISTTILES RESTORED
                  // ------------------------------
                  ListTile(
                    leading: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),
                    title: const Text("Theme"),
                    subtitle: Text(isDarkMode ? "Dark Mode" : "Light Mode"),
                    trailing: Switch.adaptive(
                      value: isDarkMode,
                      onChanged: (value) {
                        widget.onThemeChanged(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.history_outlined),
                    title: const Text("Order History"),
                    onTap: () => Navigator.pushNamed(context, '/order-history'),
                  ),

                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text("Delivery Addresses"),
                    onTap: () => Navigator.pushNamed(context, '/addresses'),
                  ),

                  ListTile(
                    leading: const Icon(Icons.add_location_alt_sharp),
                    title: const Text("Add Delivery Location"),
                    onTap: () => Navigator.pushNamed(context, '/add_address'),
                  ),

                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text("Change Password"),
                    onTap: () =>
                        Navigator.pushNamed(context, '/password_reset'),
                  ),

                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text("Settings"),
                  ),

                  ListTile(
                    leading: const Icon(Icons.support_agent),
                    title: const Text("Contact Us"),
                    onTap: () => Navigator.pushNamed(context, '/contact_us'),
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      await AuthService.clearAuth();
                      if (!mounted) return;
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
