import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rental_ps_kesekiankalinya/modal/api.dart';
import 'package:rental_ps_kesekiankalinya/modal/psModel.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final money = NumberFormat("#,##0", "en_US");

  var loading = false;
  final list = <psModel>[];
  final GlobalKey<RefreshIndicatorState> _refresh = GlobalKey<
      RefreshIndicatorState>();

  Future<void> _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });

    try {
      final response = await http.get(Uri.parse(BaseUrl.getPlaystations));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        data.forEach((api) {
          final ab = psModel(
            api["id_ps"],
            api["bilik"],
            api["jenis_ps"],
            api["daftar_game"],
            api["harga"],
            api["idUsers"],
            api["nama"],
            api["gambar"],
            api["status"],
          );
          list.add(ab);
        });
      } else {
        print("Failed to load data");
      }
    } catch (error) {
      print("Error: $error");
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _lihatData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _lihatData,
        key: _refresh,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final x = list[i];
                  return Container(
                    padding: EdgeInsets.all(10.0),
                    key: Key(x.idPs.toString()),
                    height: 180.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 90.0,
                          height: 90.0,
                          child: Image.network(
                            'http://192.168.150.48/ps/upload/' + x.gambar,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 15.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Bilik ${x.bilik}',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(x.jenisPs),
                              SizedBox(height: 5.0),
                              Text(
                                x.daftarGame.length > 20
                                    ? x.daftarGame.substring(0, 20) + "..."
                                    : x.daftarGame,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              SizedBox(height: 5.0),
                              Text('Rp. ${money.format(int.parse(x.harga))}'),
                              SizedBox(height: 5.0),
                              Text('Status : ${x.status}'),
                              SizedBox(height: 5.0),
                              Text('Admin : ${x.nama}'),
                            ],
                          ),
                        ),
                        SizedBox(width: 15.0),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
