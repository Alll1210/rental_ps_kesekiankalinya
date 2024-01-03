import 'package:flutter/material.dart';
import 'package:rental_ps_kesekiankalinya/view/add_playstations.dart'; // Sesuaikan path ke file add_playstations.dart

class Playstations extends StatefulWidget {
  const Playstations({Key? key}) : super(key: key);

  @override
  State<Playstations> createState() => _PlaystationsState();
}

class _PlaystationsState extends State<Playstations> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPlaystations()), // Sesuaikan dengan nama kelas yang benar
          );
        },
      ),
      body: Center(
        child: Text("Playstations"),
      ),
    );
  }
}
