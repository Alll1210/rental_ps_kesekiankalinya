import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rental_ps_kesekiankalinya/modal/api.dart';
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
  String nama = ''; // Tambahkan variabel untuk nama lengkap
  final _key = GlobalKey<FormState>();
  bool _secureText = true; // Perbaiki nilai awal _secureText menjadi true
  bool _isLoading = false;

  void showHide() {
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

  Future<void> login() async {
    setState(() {
      _isLoading = true;
    });

    final Uri uri = Uri.parse(BaseUrl.login);

    try {
      final response = await http.post(uri, body: {
        "username": username,
        "password": password,
      });

      if (response.statusCode == 200) {
        handleLoginResponse(response);
      } else {
        print("Error: ${response.statusCode}");
        showErrorMessage("Failed to connect to the server");
      }
    } catch (error) {
      print("Error: $error");
      showErrorMessage("An unexpected error occurred");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void handleLoginResponse(http.Response response) {
    final data = jsonDecode(response.body);
    int? value = data['value'] as int?;
    String pesan = data['message'];
    String usernameAPI = data['username'] ?? '';
    String namaAPI = data['nama'] ?? '';

    if (value == 1) {
      savePref(value ?? 0, usernameAPI, namaAPI);
      showSuccessMessage("Login successful");
    } else {
      print("Login failed: $pesan");
      showErrorMessage("Login failed: $pesan");
    }
  }

  void savePref(int value, String username, String nama) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("value", value);
    preferences.setString("nama", nama); // Simpan nama lengkap
    preferences.setString("username", username);

    setState(() {
      _loginStatus = LoginStatus.signIn;
      // Set nilai variabel nama
      this.nama = nama;
    });
  }

  void signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove("value");

    setState(() {
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  void showErrorMessage(String message) {
    // Implement your error message display logic here
    print("Error: $message");
  }

  void showSuccessMessage(String message) {
    // Implement your success message display logic here
    print(message);
  }

  var value;

  void getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");
      if (value == 1) {
        username = preferences.getString("username") ?? '';
        // Add this line
        nama = preferences.getString("nama") ?? '';
        _loginStatus = LoginStatus.signIn;
      } else {
        _loginStatus = LoginStatus.notSignIn;
      }
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
        return buildLoginForm();
        break;
      case LoginStatus.signIn:
        return Dashboard(signOut: signOut);
        break;
    }
  }

  Widget buildLoginForm() {
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
                onSaved: (value) => username = value ?? '',
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
                onSaved: (value) => password = value ?? '',
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
                onPressed: _isLoading ? null : check,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text("Login"),
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
  }
}
