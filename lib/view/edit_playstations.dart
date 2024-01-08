import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rental_ps_kesekiankalinya/modal/psModel.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rental_ps_kesekiankalinya/modal/api.dart';

class EditPlaystations extends StatefulWidget {
  final psModel model;
  final VoidCallback reload;
  EditPlaystations(this.model, this.reload);

  @override
  State<EditPlaystations> createState() => _EditPlaystationsState();
}

class _EditPlaystationsState extends State<EditPlaystations> {
  final _key = GlobalKey<FormState>();
  String bilik = '', jenisPs = '', daftarGame = '', harga = '', idUser = '', id_ps = '';
  File? _imageFile;

  _pilihGallery() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 1920.0,
      maxWidth: 1080.0,
    );
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  TextEditingController txtBilik = TextEditingController();
  TextEditingController txtJenis = TextEditingController();
  TextEditingController txtGame = TextEditingController();
  TextEditingController txtHarga = TextEditingController();

  @override
  void initState() {
    super.initState();
    setup();
  }

  void setup() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idUser = preferences.getString("id") ?? '';
      id_ps = preferences.getString("id_ps") ?? '';
    });
    txtBilik.text = widget.model.bilik ?? '';
    txtJenis.text = widget.model.jenisPs ?? '';
    txtGame.text = widget.model.daftarGame ?? '';
    txtHarga.text = widget.model.harga ?? '';
  }

  void check() {
    final form = _key.currentState;
    if (form != null && form.validate()) {
      form.save();
      submit();
    }
  }

  void submit() async {
    try {
      var uri = Uri.parse(BaseUrl.editPlaystations);
      var request = http.MultipartRequest("POST", uri);

      request.fields['bilik'] = bilik;
      request.fields['jenis_ps'] = jenisPs;
      request.fields['daftar_game'] = daftarGame;
      request.fields['harga'] = harga.replaceAll(",", "");
      request.fields['id_ps'] = widget.model.idPs;

      if (_imageFile != null) {
        var stream = http.ByteStream(DelegatingStream.typed(_imageFile!.openRead()));
        var length = await _imageFile!.length();
        request.files.add(http.MultipartFile.fromBytes(
          'gambar',
          await _imageFile!.readAsBytes(),
          filename: path.basename(_imageFile!.path),
        ));
      }

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = utf8.decode(responseData);

      print("Response String: $responseString");  // Tambahkan baris ini untuk melihat responseString di konsol

      final data = jsonDecode(responseString);
      int value = data['value'];
      String pesan = data['message'];

      if (value == 1) {
        setState(() {
          widget.reload();
          Navigator.pop(context);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Data berhasil diupdate!'),
          duration: Duration(seconds: 2),
        ));
      } else {
        print(pesan);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal mengupdate data: $pesan'),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      print("Error: $e");  // Tambahkan baris ini untuk melihat pesan kesalahan di konsol
      debugPrint("Error $e");
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
            Container(
              width: double.infinity,
              height: 200.0,
              child: InkWell(
                onTap: _pilihGallery,
                child: _imageFile == null
                    ? Image.network('http://192.168.150.48/ps/upload/' + widget.model.gambar)
                    : Image.file(
                  _imageFile!,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            TextFormField(
              enabled: false,
              controller: txtBilik,
              onSaved: (e) => bilik = e ?? '',
              decoration: InputDecoration(labelText: 'Bilik'),
            ),
            TextFormField(
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
