import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rental_ps_kesekiankalinya/modal/api.dart';
import 'package:rental_ps_kesekiankalinya/modal/psModel.dart';
import 'package:rental_ps_kesekiankalinya/view/edit_playstations.dart';
import 'add_playstations.dart';
import 'package:intl/intl.dart';

class Playstations extends StatefulWidget {
  const Playstations({Key? key}) : super(key: key);

  @override
  State<Playstations> createState() => _PlaystationsState();
}

class _PlaystationsState extends State<Playstations> {
  final money = NumberFormat("#,##0","en_US");

  var loading = false;
  final list = <psModel>[];
  final GlobalKey<RefreshIndicatorState> _refresh = GlobalKey<RefreshIndicatorState>();

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

  void dialogDelete(String idBilik) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ListView(
            padding: EdgeInsets.all(16.0),
            shrinkWrap: true,
            children: <Widget>[
              Text("Hapus Data PS?",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                      child: Text("Batal")),
                  SizedBox(
                    width: 16.0,
                  ),
                  InkWell(
                    onTap: (){
                      _delete(idBilik);
                    },
                      child: Text("Hapus"))
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _delete(String idBilik) async {
    final response = await http.post(
      Uri.parse(BaseUrl.deletePlaystations),
      body: {
        "id_bilik": idBilik,
      },
    );

    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    if (value == 1) {
      setState(() {
        Navigator.pop(context);
        _lihatData();
      });
    } else {
      print(pesan);
    }
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
            MaterialPageRoute(builder: (context) => AddPlaystations(_lihatData)),
          );
        },
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _lihatData,
        key: _refresh,
        child: ListView.builder(
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
                        Text(x.jenisPs, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                        Text(x.daftarGame),
                        Text(money.format(int.parse(x.harga))),
                        Text(x.nama),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context)=>EditPlaystations(x, _lihatData)
                      ));
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      dialogDelete(x.idBilik);
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
