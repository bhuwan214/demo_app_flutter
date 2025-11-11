import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profileImage;
  String name = "Bhuwan Kathayat";
  String email = "bhuwan@example.com";
  String location = "Kathmandu, Nepal";

  final List<Map<String, String>> orderHistory = [
    {"orderId": "#1001", "item": "OKF Smoothie 350ML", "date": "Nov 10, 2025"},
    {"orderId": "#1002", "item": "Veggie Noodles 112g", "date": "Nov 08, 2025"},
    {"orderId": "#1003", "item": "Premium Coffee Beans 250g", "date": "Nov 02, 2025"},
  ];

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = picked.path;
      });
    }
  }

  void _editProfileInfo() async {
    String tempName = name;
    String tempEmail = email;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Name"),
                controller: TextEditingController(text: name),
                onChanged: (value) => tempName = value,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: "Email"),
                controller: TextEditingController(text: email),
                onChanged: (value) => tempEmail = value,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {"name": tempName, "email": tempEmail}),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        name = result["name"] ?? name;
        email = result["email"] ?? email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar:AppBar(
        title:const Text("Profile Page"),
        centerTitle:true,
        backgroundColor:theme.colorScheme.primaryContainer,
      ),
   
      body: ListView(
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
                      backgroundImage: _profileImage != null
                          ? Image.asset(_profileImage!).image
                          : const AssetImage('assets/default_avatar.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                          onPressed: _pickProfileImage,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),

                // Name & Email with edit button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name, style: theme.textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: _editProfileInfo,
                    ),
                  ],
                ),
                Text(email, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 10),

              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),

          // Order History Section
          Text("Order History", style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          ...orderHistory.map((order) => Card(
                child: ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: Text(order['item']!),
                  subtitle: Text(order['date']!),
                  trailing: Text(order['orderId']!),
                ),
              )),

          const SizedBox(height: 20),
          const Divider(),

          // Settings Section
          Text("Settings", style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
      ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Change Password"),
            onTap: () {},
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
          
          ListTile(
            leading: const Icon(Icons.add_location_alt_sharp),
            title: const Text("Location"),
            onTap: () {},
          ),
            ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
