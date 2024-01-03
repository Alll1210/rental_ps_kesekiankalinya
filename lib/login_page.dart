import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard.dart';
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
  String password = ''; // Mengatasi nullable String
  final _key = new GlobalKey<FormState>();

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
    int value = data['value'];
    String pesan = data['message'];
    if (value == 1) {
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(value);
      });
      print(pesan);
    } else {
      print(pesan);
    }
    print(data);
  }

  savePref(int value)async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", value);
      preferences.commit();
    });
  }

  var value;
  getPref()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");

      _loginStatus = value == 1 ?  LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
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
                    username = value ?? '', // Mengatasi nullable String
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
                    password = value ?? '', // Mengatasi nullable String
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
                ],
              ),
            ),
          ),
        );
        break;
      case LoginStatus.signIn:
        return Dashboard(); // Menggunakan Dashboard setelah login
        break;
    }
  }
}
