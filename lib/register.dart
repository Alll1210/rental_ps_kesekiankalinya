import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rental_ps_kesekiankalinya/modal/api.dart';

class Register extends StatefulWidget {
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? username, password, nama; // Tambahkan tanda "?" untuk mengatasi nullable String
  final _key = GlobalKey<FormState>();

  bool _secureText = false;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form != null && form.validate()) {
      form.save();
      save();
    }
  }

  save() async {
    final response = await http.post(Uri.parse(BaseUrl.register), body: {
      "nama": nama,
      "username": username,
      "password": password
    });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    if (value == 1) {
      setState(() {
        Navigator.pop(context);
      });
    } else {
      print(pesan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Masukkan Nama Lengkap";
                }
                return null;
              },
              onSaved: (value) => nama = value,
              decoration: InputDecoration(
                labelText: "Nama Lengkap",
              ),
            ),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Masukkan Username";
                }
                return null;
              },
              onSaved: (value) => username = value,
              decoration: InputDecoration(
                labelText: "Username",
              ),
            ),
            TextFormField(
              obscureText: _secureText,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Masukkan Password";
                }
                return null;
              },
              onSaved: (value) => password = value,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  onPressed: showHide,
                  icon: Icon(
                      _secureText ? Icons.visibility_off : Icons.visibility),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                check();
              },
              child: Text("Daftar"),
            ),
          ],
        ),
      ),
    );
  }
}
