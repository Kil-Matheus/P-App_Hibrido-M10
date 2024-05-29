import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CameraController {
  final picker = ImagePicker();
  final String _baseUrl = dotenv.env['API_URL']!;

  Future<File?> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<File?> uploadImage(File image) async {
    final uri = Uri.parse('$_baseUrl/upload');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', image.path))
      ..fields['filter'] = 'BLUR';

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/filtered_image.jpg';
      final file = File(filePath);
      file.writeAsBytesSync(responseData.bodyBytes);
      return file;
    } else {
      print('Failed to upload image');
      return null;
    }
  }
}
