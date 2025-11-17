import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'services/auth_service.dart';
import 'pages/edit_profile_dialog.dart';

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
  String name = "User";
  String phoneNumber = "";
  String email = "";
  String firstName = "";
  String lastName = "";
  String username = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    final userData = await AuthService.getUserData();
    
    if (userData != null) {
      setState(() {
        firstName = userData['first_name'] ?? '';
        lastName = userData['last_name'] ?? '';
        username = userData['username'] ?? '';
        name = '$firstName $lastName'.trim();
        if (name.isEmpty) {
          name = username.isNotEmpty ? username : (userData['display_name'] ?? 'User');
        }
        phoneNumber = userData['mobile_no'] ?? '';
        email = userData['email'] ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEditProfileDialog() {
    EditProfileDialog.show(
      context: context,
      firstName: firstName,
      lastName: lastName,
      username: username,
      onProfileUpdated: (newFirstName, newLastName, newUsername) {
        if (mounted) {
          setState(() {
            firstName = newFirstName;
            lastName = newLastName;
            username = newUsername;
            name = '$firstName $lastName'.trim();
            if (name.isEmpty) {
              name = username.isNotEmpty ? username : 'User';
            }
          });
        }
      },
    );
  }

  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (picked != null && mounted) {
        setState(() {
          _profileImage = picked.path;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Image + Info
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: _profileImage != null
                          ? FileImage(File(_profileImage!))
                          : null,
                      child: _profileImage == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          onPressed: _pickProfileImage,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),

                // User Name
                Text(
                  name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Phone Number
                if (phoneNumber.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        phoneNumber,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                
                // Email
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Edit Profile Button
                ElevatedButton.icon(
                  onPressed: _showEditProfileDialog,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),

          // Theme Toggle as ListTile
          ListTile(
            leading: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: const Text("Theme"),
            subtitle: Text(isDarkMode ? "Dark Mode" : "Light Mode"),
            trailing: Switch.adaptive(
              value: isDarkMode,
              onChanged: (value) {
                widget.onThemeChanged(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),

          const Divider(),
          const SizedBox(height: 10),

          // Order History Section
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text("Order History"),
            onTap: () {
              Navigator.pushNamed(context, '/order-history');
            },
          ),

          ListTile(
            leading: const Icon(Icons.add_location_alt_sharp),
            title: const Text("Add Delivery Location"),
            onTap: () {
              Navigator.pushNamed(context, '/add_address');
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Change Password"),
            onTap: () {
              Navigator.pushNamed(context, '/password_reset');
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text("Settings"),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text("Contact Us"),
            onTap: () {
              Navigator.pushNamed(context, '/contact_us');
            },
          ),

          const Divider(),
          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        // Clear auth data
                        await AuthService.clearAuth();
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(context, '/login');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logged out successfully'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Color.fromARGB(255, 241, 238, 238)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}