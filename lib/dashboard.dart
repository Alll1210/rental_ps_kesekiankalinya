import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  final VoidCallback signOut;

  Dashboard({Key? key, required this.signOut}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String username = "";
  String nama = "";

  @override
  void initState() {
    super.initState();
    getPref();
  }

  Future<void> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      username = preferences.getString("username") ?? "";
      nama = preferences.getString("nama") ?? "";
    });
  }

  void _signOut() {
    setState(() {
      widget.signOut();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _signOut();
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Text("Username: $username\nNama: $nama"),
      ),
    );
  }
}
