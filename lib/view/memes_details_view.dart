import 'package:developertest/model/memes_model.dart';
import 'package:developertest/utlis/label.dart';
import 'package:developertest/view_model/image_editing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemesDetailsView extends StatelessWidget {
  final Memes memes;
  const MemesDetailsView({super.key, required this.memes, });

  @override
  Widget build(BuildContext context) {
    final ImageEditorController controller = Get.put(ImageEditorController());
    Future.delayed(Duration.zero, () {
      print(memes.url!);
      controller.loadImageFromUrl(memes.url!);
    });
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              controller.clearImage(); // Call the callback to clear the image
              Get.back(); // Go back to the previous screen
            },
          ),
        title: Label(text: memes.name!)
      ),
      body: Obx(() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          controller.imageFile.value != null
              ? Image.file(controller.imageFile.value!)
              : const Text('No image loaded'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: controller.imageFile.value != null
                    ? controller.cropImage
                    : null,
                child: const Text('Crop'),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.imageFile.value != null
                ? controller.saveImageToGallery
                : null,
            child: const Text('Save Image'),
          ),
        ],
      )),
    );
  }
}
