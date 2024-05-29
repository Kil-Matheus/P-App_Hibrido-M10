import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cadastrar.dart';
import 'package:app_hibrido/camera.dart';
import 'package:app_hibrido/services/notification.dart';

void main() {
  NotificationService.init();
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    NotificationService.allowed();
    super.initState();
  }
    
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  // final _serverUri = TextEditingController();
  String _message = '';

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      

      try {
        final response = await http.post(
          Uri.parse('http://172.20.10.7:8000/login'), // IP do host - Máquina WLAN - Nginx
          //Uri.parse('http://${_serverUri.text}'), // IP do host - Máquina WLAN - Nginx
          //Uri.parse('http://172.17.0.1:8000/login'),  // IP do host - Máquina - Nginx
          //Uri.parse('http://172.18.0.5:8000/login'),  // IP do host - Endereço de Rede (Fica trocando)- Nginx
          //Uri.parse('http://172.18.0.4:5000/login'), // IP do host - Endereço de Rede - Flutter Simulado
          //Uri.parse('http://172.17.0.1:5000/login'), //Ip do host - Máquina - Docker Compose s/ Nginx - 5000 Flask
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(<String,String>{'email': username, 'password': password}),
        );
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          setState(() {
            _message = responseData['message'];
            NotificationService.showNotification('Login', 'Bem vindo $username');
          });
        } else {
          setState(() {
            _message = 'Erro de servidor: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          _message = 'Erro de rede: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              SizedBox(height: 20),
              Text(
                _message,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CadastrarPage()),
                  );
                },
                child: Text('Cadastrar'),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FilteredImagePage()),
                    );
                  },
                  child: Text('Camera'),
                ),
              // ),
              // TextField(
              //   controller: _serverUri,
              //   decoration: InputDecoration(labelText: 'URI do Servidor'),
              
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
