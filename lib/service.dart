
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:http_parser/http_parser.dart'; // Add for MIME type support
import 'object_model.dart';

class ApiService {
  String? getFileExtension(String filePath) {
    return filePath.split('.').last;
  }

  bool isValidImageFile(File file) {
    List<String> validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
    String? extension = getFileExtension(file.path);
    return extension != null && validExtensions.contains(extension.toLowerCase());
  }

  Future<ObjectPrediction?> fetchDataFromApi(File file, String endpoint) async {
    if (!file.existsSync()) {
      print('Error: File does not exist');
      return null;
    }

    // Validate file type
    if (!isValidImageFile(file)) {
      Fluttertoast.showToast(msg: 'Invalid file type. Please upload an image.');
      return null;
    }

    final Uri url = Uri.parse("http://192.168.100.3:8000/$endpoint");


    try {
      var request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('image', getFileExtension(file.path) ?? 'jpeg'), // Set MIME type based on file extension
        ))
        ..headers.addAll({
          'Accept': 'application/json',
        });

      var streamedResponse = await request.send().timeout(Duration(seconds: 60));

      if (streamedResponse.statusCode == 200) {
        final responseBody = await streamedResponse.stream.bytesToString();
        print(responseBody); // or response.body

        if (responseBody.isEmpty) {
          Fluttertoast.showToast(msg: 'Empty response from API');
          return null;
        }

        final jsonData = json.decode(responseBody);
        return ObjectPrediction.fromJson(jsonData);
      } else {
        final responseBody = await streamedResponse.stream.bytesToString();
        return null;
      }
    } catch (e) {
      if (e is SocketException) {
        Fluttertoast.showToast(msg: 'No internet connection');
      } else if (e is TimeoutException) {
        Fluttertoast.showToast(msg: 'Request timed out');
      } else {
        Fluttertoast.showToast(msg: 'Error: $e');
        print('Error: $e');
      }
      return null;
    }
  }
}

