import 'package:developertest/model/memes_model.dart';
import 'package:developertest/repository/memes_repo.dart';
import 'package:get/get.dart';


class MemesController extends GetxController {
  var memes = <Memes>[].obs;
  var filteredMemes = <Memes>[].obs;
  var isLoading = true.obs;

  final MemesService memesService = MemesService();

  @override
  void onInit() {
    fetchMemes();
    super.onInit();
  }

  void fetchMemes() async {
    try {
      isLoading(true);
      MemesModel memesModel = await memesService.fetchMemes();
      if (memesModel.success == true) {
        memes.assignAll(memesModel.data?.memes ?? []);
        filteredMemes.assignAll(memes);
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading(false);
    }
  }

  void filterMemes(String query) {
    if (query.isNotEmpty) {
      filteredMemes.assignAll(
        memes.where((meme) => meme.name?.toLowerCase().contains(query.toLowerCase()) ?? false).toList(),
      );
    } else {
      filteredMemes.assignAll(memes);
    }
  }
}
