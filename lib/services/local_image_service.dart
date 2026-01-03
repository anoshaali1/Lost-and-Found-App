import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart'; // Add this line

class LocalImageService {
  /// Saves an image file to the local documents directory.
  /// returns the absolute path of the saved image.
  static Future<String?> saveImage(File imageFile) async {
    try {
      // 1. Get the local app directory
      final directory = await getApplicationDocumentsDirectory();
      
      // 2. Create a unique filename using timestamp
      final String extension = p.extension(imageFile.path).isNotEmpty 
          ? p.extension(imageFile.path) 
          : '.jpg';
      final String fileName = 'item_${DateTime.now().millisecondsSinceEpoch}$extension';
      
      // 3. Define the full path
      final String fullPath = p.join(directory.path, fileName);
      
      // 4. Copy the file from temporary cache to permanent storage
      final File savedImage = await imageFile.copy(fullPath);
      
      return savedImage.path;
    } catch (e) {
      debugPrint("Error saving local image: $e");
      return null;
    }
  }

  /// Safely deletes a local image when an item is deleted
  static Future<void> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint("Error deleting local image: $e");
    }
  }
}