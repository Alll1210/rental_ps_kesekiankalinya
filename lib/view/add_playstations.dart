import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rental_ps_kesekiankalinya/custom/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rental_ps_kesekiankalinya/modal/api.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:image_picker/image_picker.dart';
import 'package:async/async.dart';
import 'package:path/path.dart' as path;


class AddPlaystations extends StatefulWidget {
  final VoidCallback reload;
  AddPlaystations(this.reload, {Key? key}) : super(key: key);

  @override
  State<AddPlaystations> createState() => _AddPlaystationsState();
}

class _AddPlaystationsState extends State<AddPlaystations> {
  String? jenisPs, daftarGame, harga, idUsers;
  final _key = GlobalKey<FormState>();
  File? _imageFile;

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

  _pilihKamera() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 1920.0,
      maxWidth: 1080.0,
    );
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void check() {
    final form = _key.currentState;
    if (form != null && form.validate()) {
      form.save();
      submit();
    }
  }

  Future<void> submit() async {
    try {
      var stream = http.ByteStream(DelegatingStream.typed(_imageFile!.openRead()));
      var length = await _imageFile!.length();
      var uri = Uri.parse(BaseUrl.addPlaystations);
      var request = http.MultipartRequest("POST", uri);
      request.fields['jenis_ps'] = jenisPs!;
      request.fields['daftar_game'] = daftarGame!;
      request.fields['harga'] = harga!.replaceAll(",", "");
      request.fields['idUsers'] = idUsers!;

      request.files.add(http.MultipartFile.fromBytes(
        'gambar',
        await _imageFile!.readAsBytes(),
        filename: path.basename(_imageFile!.path),
      ));
      var response = await request.send();
      if (response.statusCode == 200) {
        print("Gambar ditambahkan");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data berhasil ditambahkan'),
          ),
        );
        setState(() {
          Navigator.pop(context);
        });
      } else {
        print("Gagal menambah gambar");
      }
    } catch (e) {
      debugPrint("Error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var placeholder = Container(
      width: double.infinity,
      height: 150.0,
      child: Image.asset('assets/placeholder.png'), // Ensure correct asset path
    );
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _key,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 200.0,
                child: InkWell(
                  onTap: () {
                    _pilihGallery();
                  },
                  child: _imageFile == null
                      ? placeholder
                      : Image.file(
                    _imageFile!,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              TextFormField(
                onSaved: (e) => jenisPs = e,
                decoration: InputDecoration(labelText: 'Jenis PS'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap isi Jenis PS';
                  }
                  return null;
                },
              ),
              TextFormField(
                onSaved: (e) => daftarGame = e,
                decoration: InputDecoration(labelText: 'Daftar Game'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap isi Daftar Game';
                  }
                  return null;
                },
              ),
              TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyFormat(),
                ],
                onSaved: (e) => harga = e,
                decoration: InputDecoration(labelText: 'Harga Per Jam'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap isi Harga Per Jam';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_key.currentState!.validate()) {
                    // Hanya submit jika formulir valid
                    check();
                  }
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
