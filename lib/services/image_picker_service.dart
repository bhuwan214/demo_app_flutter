import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  static Future<String?> pickFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress image to 85% quality
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        // Save to app directory
        final savedPath = await _saveImageToAssets(pickedFile.path);
        return savedPath;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Take photo from camera
  static Future<String?> takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compress image to 85% quality
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        // Save to app directory
        final savedPath = await _saveImageToAssets(pickedFile.path);
        return savedPath;
      }
      return null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Show bottom sheet to choose between camera and gallery
  static Future<String?> showImageSourceDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    return await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Choose Profile Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),

                // Camera Option
                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    final imagePath = await takePhoto();
                    if (context.mounted) {
                      Navigator.pop(context, imagePath);
                    }
                  },
                ),

                // Gallery Option
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    final imagePath = await pickFromGallery();
                    if (context.mounted) {
                      Navigator.pop(context, imagePath);
                    }
                  },
                ),

                // Cancel Option
                ListTile(
                  leading: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 28,
                  ),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Save image to app's document directory
  static Future<String> _saveImageToAssets(String imagePath) async {
    try {
      // Get app document directory
      final appDir = await getApplicationDocumentsDirectory();
      final profileImagesDir = Directory('${appDir.path}/profile_images');

      // Create directory if it doesn't exist
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imagePath);
      final fileName = 'profile_$timestamp$extension';
      final savedImagePath = '${profileImagesDir.path}/$fileName';

      // Copy image to app directory
      final File sourceFile = File(imagePath);
      await sourceFile.copy(savedImagePath);

      debugPrint('Image saved to: $savedImagePath');
      return savedImagePath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      rethrow;
    }
  }

  /// Delete old profile image
  static Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted image: $imagePath');
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  /// Get saved profile image path from SharedPreferences
  static Future<String?> getSavedProfileImage() async {
    try {
      // You can integrate with SharedPreferences or your auth service
      // For now, returning null - implement based on your needs
      return null;
    } catch (e) {
      debugPrint('Error getting saved profile image: $e');
      return null;
    }
  }

  /// Save profile image path to SharedPreferences
  static Future<void> saveProfileImagePath(String imagePath) async {
    try {
      // You can integrate with SharedPreferences or your auth service
      // Store the image path for persistence
      debugPrint('Profile image path saved: $imagePath');
    } catch (e) {
      debugPrint('Error saving profile image path: $e');
    }
  }
}
