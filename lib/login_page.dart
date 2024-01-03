import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String username = '';
  String password = ''; // Mengatasi nullable String
  final _key = new GlobalKey<FormState>();

  void check() {
    final form = _key.currentState;
    if (form != null && form.validate()) {
      form.save();
      login();
    }
  }

  void login() async {
    final Uri uri = Uri.parse("http://192.168.124.136/ps/API/login.php");
    final response = await http.post(uri, body: {
      "username": username,
      "password": password,
    });
    final data = jsonDecode(response.body);
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Form(
        key: _key,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Masukkan Username";
                  }
                  return null;
                },
                onSaved: (value) => username = value ?? '', // Mengatasi nullable String
                decoration: InputDecoration(
                  labelText: "Username",
                ),
              ),
              TextFormField(
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Masukkan Password";
                  }
                  return null;
                },
                onSaved: (value) => password = value ?? '', // Mengatasi nullable String
                decoration: InputDecoration(
                  labelText: "Password",
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  check();
                },
                child: Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
