import 'package:flutter/material.dart';

class Playstations extends StatefulWidget {
  const Playstations({super.key});

  @override
  State<Playstations> createState() => _PlaystationsState();
}

class _PlaystationsState extends State<Playstations> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){},
      ),
      body: Center(
        child: Text("Playstations")
      ),
    );
  }
}
