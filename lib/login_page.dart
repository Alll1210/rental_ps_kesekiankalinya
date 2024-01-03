import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard.dart';
import 'register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus {
  notSignIn,
  signIn
}

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;

  String username = '';
  String password = '';
  final _key = GlobalKey<FormState>();

  bool _secureText = false;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

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
    int? value = data['value'] as int?; // Menggunakan tipe data nullable (int?)
    String pesan = data['message'];
    String usernameAPI = data['username'] ?? ''; // Menggunakan nilai default jika null
    String namaAPI = data['nama'] ?? ''; // Menggunakan nilai default jika null

    if (value == 1) {
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(value ?? 0, usernameAPI, namaAPI);
      });
      print(pesan);
    } else {
      print(pesan);
    }
    print(data);
  }


  savePref(int value, String username, String nama) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("value", value);
    preferences.setString("nama", nama);
    preferences.setString("username", username);
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove("value");
    setState(() {
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  var value;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");
      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
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
                    onSaved: (value) =>
                    username = value ?? '',
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
                    onSaved: (value) =>
                    password = value ?? '',
                    decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: IconButton(
                          onPressed: showHide,
                          icon: Icon(
                              _secureText ? Icons.visibility_off : Icons.visibility),
                        )
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      check();
                    },
                    child: Text("Login"),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Register()));
                    },
                    child: Text("Daftar Akun", textAlign: TextAlign.center,),
                  )
                ],
              ),
            ),
          ),
        );
        break;
      case LoginStatus.signIn:
        return Dashboard(signOut: signOut);
        break;
    }
  }
}
