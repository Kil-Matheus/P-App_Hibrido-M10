import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_hibrido/models/user_model.dart';
import 'package:app_hibrido/services/notification.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegisterController {
  final String _baseUrl = dotenv.env['API_URL']!;

  Future<String> register(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': user.email, 'password': user.password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        NotificationService.showNotification('Cadastro', 'O ${user.email} foi cadastrado com sucesso');
        return responseData['message'];
      } else {
        return 'Erro de servidor: ${response.statusCode}';
      }
    } catch (e) {
      return 'Erro de rede: $e';
    }
  }
}
