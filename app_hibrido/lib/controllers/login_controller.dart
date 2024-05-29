import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_hibrido/models/user_model.dart';
import 'package:app_hibrido/services/notification.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginController {
  Future<String> login(UserModel user) async {
  final String _baseUrl = dotenv.env['API_URL']!;

    try {
      final response = await http.post(
            Uri.parse('$_baseUrl/login'), // IP do host - Máquina WLAN - Nginx
          //Uri.parse('http://${_serverUri.text}'), // IP do host - Máquina WLAN - Nginx
          //Uri.parse('http://172.17.0.1:8000/login'),  // IP do host - Máquina - Nginx
          //Uri.parse('http://172.18.0.5:8000/login'),  // IP do host - Endereço de Rede (Fica trocando)- Nginx
          //Uri.parse('http://172.18.0.4:5000/login'), // IP do host - Endereço de Rede - Flutter Simulado
          //Uri.parse('http://172.17.0.1:5000/login'), //Ip do host - Máquina - Docker Compose s/ Nginx - 5000 Flask
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': user.email, 'password': user.password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        NotificationService.showNotification('Login', 'Bem vindo ${user.email}');
        return responseData['message'];
      } else {
        return 'Erro de servidor: ${response.statusCode}';
      }
    } catch (e) {
      return 'Erro de rede: $e';
    }
  }
}
