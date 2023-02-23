import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PersonelMapScreen extends StatefulWidget {
  const PersonelMapScreen({super.key});

  @override
  State<PersonelMapScreen> createState() => _PersonelMapScreenState();
}

class _PersonelMapScreenState extends State<PersonelMapScreen> {
  GoogleMapController? _controller = null;

  Set<Marker> getMarkers() {
    return {
      Marker(
          markerId: MarkerId("1"),
          position: LatLng(40.188526, 29.060965),
          infoWindow: InfoWindow(title: "Test Title", snippet: "Test Snippet"))
    };
  }

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
        markers: getMarkers(),
        onMapCreated: (controller) async {
          _controller = controller;
          /*String value = await DefaultAssetBundle.of(context)
              .loadString('lib/assets/style/map-style.json');
          controller.setMapStyle(value);
          setState(() {});*/
        },
      ),
    );
  }
}
