import 'package:flutter/material.dart';
import 'package:rental_ps_kesekiankalinya/view/home.dart';
import 'package:rental_ps_kesekiankalinya/view/playstations.dart';
import 'package:rental_ps_kesekiankalinya/view/profile.dart';
import 'package:rental_ps_kesekiankalinya/view/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  final VoidCallback signOut;

  Dashboard({Key? key, required this.signOut}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  String username = "";
  String nama = "";

  late TabController tabController; // Menggunakan late untuk inisialisasi nanti

  Future<void> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      username = preferences.getString("username") ?? "";
      nama = preferences.getString("nama") ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
    tabController = TabController(length: 4, vsync: this);
  }

  void _signOut() {
    setState(() {
      widget.signOut();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
        body: TabBarView(
          controller: tabController,
          children: <Widget>[
            Home(),
            Playstations(),
            User(),
            Profile()
          ],
        ),
        bottomNavigationBar: TabBar(
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                  style: BorderStyle.none
              )
          ),
          controller: tabController,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.home),
              text: "Home",
            ),
            Tab(
              icon: Icon(Icons.gamepad),
              text: "Playstations",
            ),
            Tab(
              icon: Icon(Icons.group),
              text: "User",
            ),
            Tab(
              icon: Icon(Icons.account_circle),
              text: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
