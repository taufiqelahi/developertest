import 'package:developertest/utlis/label.dart';
import 'package:developertest/view/memes_details_view.dart';
import 'package:developertest/view_model/image_controller.dart';
import 'package:developertest/view_model/memes_view_model_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final MemesController memesController = Get.put(MemesController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Memes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                memesController.filterMemes(value);
              },
              decoration: InputDecoration(
                labelText: 'Search by name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: Obx(() {
                if (memesController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                return MasonryGridView.builder(
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: memesController.filteredMemes.length,
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                    // Spacing between columns
                  ),
                  itemBuilder: (context, index) {
                    final meme = memesController.filteredMemes[index];
                    return InkWell(
                      onTap: () {
                        Get.to(() => ImageEditorScreen(
                              memes: meme,
                              onBack: () {
                                final controller =
                                    Get.find<ImageEditorController>();
                                controller
                                    .clearImage(); // Clear the image when navigating back
                                Get.delete<ImageEditorController>();
                              },
                            ));
                      },
                      child: Card(
                        elevation: 4, // Shadow effect
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            meme.url != null && meme.url!.isNotEmpty
                                ? Image.network(
                                    meme.url!,
                                    width: double
                                        .infinity, // Use full width of the card
                                    height:
                                        150, // Set a fixed height for the images
                                    fit: BoxFit.cover,
                                  )
                                : Placeholder(
                                    fallbackHeight: 150,
                                    fallbackWidth: double.infinity,
                                  ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Label(
                                text: meme.name!,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
