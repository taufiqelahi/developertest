import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saver_gallery/saver_gallery.dart';

class ImageEditorScreen extends StatefulWidget {
  @override
  _ImageEditorScreenState createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  File? _imageFile;

  // Method to pick an image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Method to crop the image
  Future<void> cropImage() async {
    if (_imageFile == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _imageFile!.path,
      aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 3), // Custom aspect ratio
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
          context: context,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _imageFile = File(croppedFile.path);
      });
    }
  }

  // Method to rotate the image
  Future<void> _rotateImage() async {
    try {
      if (_imageFile == null) return;

      final img.Image originalImage = img.decodeImage(_imageFile!.readAsBytesSync())!;
      final img.Image rotatedImage = img.copyRotate(originalImage, angle: 90);

      final tempDir = await getTemporaryDirectory();
      final rotatedFile = File('${tempDir.path}/rotated_image.png')
        ..writeAsBytesSync(img.encodePng(rotatedImage));

      setState(() {
        _imageFile = rotatedFile;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rotating image: $e')),
      );
    }
  }

  // Method to save the image




  Future<void> _saveImageToExternalStorage() async {
    if (_imageFile == null) return; // Ensure there's an image

    // Request manage storage permission (for Android 11+)
    PermissionStatus status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }

    if (status.isGranted) {
      try {
        // Get external storage directory (e.g., Downloads)
        final directory = Directory('/storage/emulated/0/Download');

        // Ensure directory exists
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        // Create file with timestamp name
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        final savedImage = File('${directory.path}/$fileName')
          ..writeAsBytesSync(_imageFile!.readAsBytesSync());

        // Notify user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to ${directory.path}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied')),
      );
    }
  }
  Future<void> _saveImageToGallery() async {
    if (_imageFile == null) return; // Ensure there's an image

    // Request storage permission (Android 10 and below)
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    // Request manage storage permission (Android 11+)
    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }

      try {
        // Read the image as bytes
        Uint8List imageBytes = _imageFile!.readAsBytesSync();

        // Save the image to the gallery using saver_gallery
        final result = await SaverGallery.saveImage(
          imageBytes,
          name: 'my_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          androidExistNotSave: false,
        );

        // Notify the user if the image is saved successfully
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image saved to gallery!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save image: ${result}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Editor'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _imageFile != null
              ? Image.file(_imageFile!)
              : Text('No image selected'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _imageFile != null ? cropImage : null,
                child: Text('Crop'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _imageFile != null ? _rotateImage : null,
                child: Text('Rotate 90°'),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _imageFile != null ? _saveImageToGallery : null,
            child: Text('Save Image'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(Icons.add_photo_alternate),
      ),
    );
  }
}
