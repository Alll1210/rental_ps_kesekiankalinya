import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rental_ps_kesekiankalinya/modal/api.dart';

class Register extends StatefulWidget {
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? username, password, nama;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pendaftaran berhasil!'),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendaftar. $pesan'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/ps_logo.png', // Change this to the correct filename
                height: 100.0,
              ),
              SizedBox(height: 16.0),
              Form(
                key: _key,
                child: Column(
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
            ],
          ),
        ),
      ),
    );
  }
}
