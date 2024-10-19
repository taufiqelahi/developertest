import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:saver_gallery/saver_gallery.dart';

class ImageEditorController extends GetxController {
  var imageFile = Rxn<File>();
  void clearImage() {
    imageFile.value = null;
  }
  // Method to load an image from a URL
  Future<void> loadImageFromUrl(String url) async {
    try {
      imageFile.value = null; // Clear the previous image

      // Download the image
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Save the image bytes to a file
        final directory = Directory.systemTemp; // Use temporary directory
        final imagePath = '${directory.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg'; // Unique filename
        final file = File(imagePath);

        // Ensure the directory exists
        if (!(await directory.exists())) {
          await directory.create(recursive: true);
        }

        await file.writeAsBytes(response.bodyBytes);

        // Check if the file was created successfully
        if (await file.exists()) {
          imageFile.value = file; // Set the image file
        } else {
          Get.snackbar('Error', 'Failed to save image file.');
        }
      } else {
        Get.snackbar('Error', 'Failed to load image from URL: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading image: $e');
    }
  }

  // Method to crop the image
  Future<void> cropImage() async {
    if (imageFile.value == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.value!.path,
      aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
          minimumAspectRatio: 1.0,
        ),
        WebUiSettings(
          context: Get.context!,
        ),
      ],
    );

    if (croppedFile != null) {
      imageFile.value = File(croppedFile.path);
    }
  }

  // Method to save the image to gallery
  Future<void> saveImageToGallery() async {
    if (imageFile.value == null) return;

    try {
      Uint8List imageBytes = imageFile.value!.readAsBytesSync();

      final result = await SaverGallery.saveImage(
        imageBytes,
        name: 'my_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        androidExistNotSave: false,
      );

      if (result.isSuccess) {
        Get.snackbar('Success', 'Image saved to gallery!');
      } else {
        Get.snackbar('Error', 'Failed to save image: $result');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error saving image: $e');
    }
  }
}
