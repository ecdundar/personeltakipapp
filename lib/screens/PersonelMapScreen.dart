import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PersonelMapScreen extends StatefulWidget {
  const PersonelMapScreen({super.key});

  @override
  State<PersonelMapScreen> createState() => _PersonelMapScreenState();
}

class _PersonelMapScreenState extends State<PersonelMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Personel Harita")),
      body: GoogleMap(),
    );
  }
}
