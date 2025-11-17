import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../services/auth_service.dart';

class EditProfileDialog {
  static Future<void> show({
    required BuildContext context,
    required String firstName,
    required String lastName,
    required String username,
    required Function(String, String, String) onProfileUpdated,
  }) async {
    final firstNameController = TextEditingController(text: firstName);
    final lastNameController = TextEditingController(text: lastName);
    final usernameController = TextEditingController(text: username);

    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (dialogContext) => _EditProfileDialogContent(
        firstNameController: firstNameController,
        lastNameController: lastNameController,
        usernameController: usernameController,
      ),
    );

    // Dispose controllers after dialog is closed
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();

    // Process the result after disposing controllers
    if (result != null && context.mounted) {
      await _updateProfile(
        context: context,
        newFirstName: result['first_name']!,
        newLastName: result['last_name']!,
        newUsername: result['username']!,
        onProfileUpdated: onProfileUpdated,
      );
    }
  }

  static Future<void> _updateProfile({
        title: const Text('Edit Profile'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.alternate_email),
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, {
                  'first_name': firstNameController.text.trim(),
                  'last_name': lastNameController.text.trim(),
                  'username': usernameController.text.trim(),
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    // Dispose controllers after dialog is closed
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();

    // Process the result after disposing controllers
    if (result != null && context.mounted) {
      await _updateProfile(
        context: context,
        newFirstName: result['first_name']!,
        newLastName: result['last_name']!,
        newUsername: result['username']!,
        onProfileUpdated: onProfileUpdated,
      );
    }
  }

  static Future<void> _updateProfile({
    required BuildContext context,
    required String newFirstName,
    required String newLastName,
    required String newUsername,
    required Function(String, String, String) onProfileUpdated,
  }) async {
    if (!context.mounted) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return PopScope(
            canPop: false,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Updating profile...'),
                  ],
                ),
              ),
            ),
          );
        },
      );

      final token = await AuthService.getToken();
      print('Token retrieved: ${token != null ? 'Yes' : 'No'}');

      if (token == null) {
        // Safely dismiss loading dialog
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication token not found'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      print('Sending profile update request...');
      print('First Name: $newFirstName, Last Name: $newLastName, Username: $newUsername');

      final response = await http.post(
        Uri.parse('https://ecommerce.atithyahms.com/api/ecommerce/customer/profile/edit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'first_name': newFirstName,
          'last_name': newLastName,
          'username': newUsername,
        }),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Close loading dialog safely
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!context.mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Profile update response: $data');

        // Update local user data
        final userData = await AuthService.getUserData() ?? {};
        userData['first_name'] = newFirstName;
        userData['last_name'] = newLastName;
        userData['username'] = newUsername;
        await AuthService.saveUserData(userData);

        // Callback to update parent widget
        onProfileUpdated(newFirstName, newLastName, newUsername);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (!context.mounted) return;

        try {
          final errorData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed: ${errorData['message'] ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update. Status: ${response.statusCode}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } on http.ClientException catch (e) {
      print('Network error: $e');

      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Please check your connection.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on TimeoutException catch (e) {
      print('Request timeout: $e');

      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request timeout. Please try again or check your internet connection.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error updating profile: $e');
      print('Stack trace: $stackTrace');

      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
