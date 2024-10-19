import 'dart:convert';
import 'package:developertest/model/memes_model.dart';
import 'package:http/http.dart' as http;

class MemesService {
  final String url = "https://api.imgflip.com/get_memes";

  Future<MemesModel> fetchMemes() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return MemesModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load memes');
    }
  }
}
