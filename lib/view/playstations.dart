import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rental_ps_kesekiankalinya/modal/api.dart';
import 'package:rental_ps_kesekiankalinya/modal/psModel.dart';
import 'add_playstations.dart';

class Playstations extends StatefulWidget {
  const Playstations({Key? key}) : super(key: key);

  @override
  State<Playstations> createState() => _PlaystationsState();
}

class _PlaystationsState extends State<Playstations> {
  var loading = false;
  final list = <psModel>[];

  _lihatData() async {
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
            api["id_bilik"],
            api["jenis_ps"],
            api["daftar_game"],
            api["harga"],
            api["idUsers"],
            api["nama"],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPlaystations()),
          );
        },
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) {
          final x = list[i];
          return Container(
            padding: EdgeInsets.all(10.0),
            key: Key(x.idBilik.toString()),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(x.jenisPs, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
                      Text(x.daftarGame),
                      Text(x.harga),
                      Text(x.nama),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: (){},
                icon: Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
