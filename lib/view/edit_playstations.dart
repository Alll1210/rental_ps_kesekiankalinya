import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rental_ps_kesekiankalinya/modal/psModel.dart';
import 'package:http/http.dart' as http;
import 'package:rental_ps_kesekiankalinya/modal/api.dart'; // Import the API file

class EditPlaystations extends StatefulWidget {
  final psModel model;
  final VoidCallback reload;
  EditPlaystations(this.model, this.reload);

  @override
  State<EditPlaystations> createState() => _EditPlaystationsState();
}

class _EditPlaystationsState extends State<EditPlaystations> {
  final _key = GlobalKey<FormState>();
  String jenisPs = '', daftarGame = '', harga = '';

  TextEditingController txtJenis = TextEditingController();
  TextEditingController txtGame = TextEditingController();
  TextEditingController txtHarga = TextEditingController();

  @override
  void initState() {
    super.initState();
    setup();
  }

  void setup() {
    txtJenis.text = widget.model.jenisPs ?? '';
    txtGame.text = widget.model.daftarGame ?? '';
    txtHarga.text = widget.model.harga ?? '';
  }

  void check() {
    final form = _key.currentState;
    if (form != null && form.validate()) {
      form.save();
      submit();
    } else {
      // Handle validation errors if needed
    }
  }

  void submit() async {
    final response = await http.post(
      Uri.parse(BaseUrl.editPlaystations),
      body: {
        "jenis_ps": jenisPs,
        "daftar_game": daftarGame,
        "harga": harga,
        "id_bilik": widget.model.idBilik,
      },
    );

    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];

    if (value == 1) {
      setState(() {
        widget.reload();
        Navigator.pop(context);
      });
    } else {
      print(pesan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              enabled: false,
              controller: txtJenis,
              onSaved: (e) => jenisPs = e ?? '',
              decoration: InputDecoration(labelText: 'Jenis PS'),
            ),
            TextFormField(
              controller: txtGame,
              onSaved: (e) => daftarGame = e ?? '',
              decoration: InputDecoration(labelText: 'Daftar Game'),
            ),
            TextFormField(
              controller: txtHarga,
              onSaved: (e) => harga = e ?? '',
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
    );
  }
}
