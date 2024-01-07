import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rental_ps_kesekiankalinya/custom/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rental_ps_kesekiankalinya/modal/api.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;


class AddPlaystations extends StatefulWidget {
  final VoidCallback reload;
  AddPlaystations(this.reload, {Key? key}) : super(key: key);

  @override
  State<AddPlaystations> createState() => _AddPlaystationsState();
}

class _AddPlaystationsState extends State<AddPlaystations> {
  String? jenisPs, daftarGame, harga, idUsers;
  final _key = GlobalKey<FormState>();

  // Gunakan async/await di dalam metode initState
  @override
  void initState() {
    super.initState();
    getPref();
  }

  Future<void> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idUsers = preferences.getString("id");
    });
  }

  void check() {
    final form = _key.currentState;
    if (form != null && form.validate()) {
      form.save();
      submit();
    }
  }

  Future<void> submit() async {
    final form = _key.currentState;
    if (form != null && form.validate()) {
      form.save();
      final response = await http.post(Uri.parse(BaseUrl.addPlaystations), body: {
        "jenis_ps": jenisPs!,
        "daftar_game": daftarGame!,
        "harga": harga!.replaceAll(",", ""),
        "idUsers": idUsers!,
      });

      final data = jsonDecode(response.body);
      int value = data['value'];
      String pesan = data['message'];

      if (value == 1) {
        print(pesan);
        setState(() {
          widget.reload();
          Navigator.pop(context);
        });
      } else {
        print(pesan);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _key,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              TextFormField(
                onSaved: (e) => jenisPs = e,
                decoration: InputDecoration(labelText: 'Jenis PS'),
              ),
              TextFormField(
                onSaved: (e) => daftarGame = e,
                decoration: InputDecoration(labelText: 'Daftar Game'),
              ),
              TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyFormat(),
                ],
                onSaved: (e) => harga = e,
                decoration: InputDecoration(labelText: 'Harga Per Jam'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  check();
                },
                child: Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
