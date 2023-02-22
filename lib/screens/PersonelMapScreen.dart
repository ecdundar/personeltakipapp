import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PersonelMapScreen extends StatefulWidget {
  const PersonelMapScreen({super.key});

  @override
  State<PersonelMapScreen> createState() => _PersonelMapScreenState();
}

class _PersonelMapScreenState extends State<PersonelMapScreen> {
  GoogleMapController? _controller = null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Personel Harita")),
      body: GoogleMap(
        myLocationButtonEnabled: true,
        mapType: MapType.hybrid,
        initialCameraPosition:
            CameraPosition(target: LatLng(40.188526, 29.060965), zoom: 15),
        compassEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,
        onMapCreated: (controller) {
          _controller = controller;
        },
      ),
    );
  }
}
