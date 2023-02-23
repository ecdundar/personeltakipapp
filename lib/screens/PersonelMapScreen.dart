import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class PersonelMapScreen extends StatefulWidget {
  const PersonelMapScreen({super.key});

  @override
  State<PersonelMapScreen> createState() => _PersonelMapScreenState();
}

class _PersonelMapScreenState extends State<PersonelMapScreen> {
  GoogleMapController? _controller = null;
  Position? currentPosition = null;

  Set<Marker> getMarkers() {
    var _marker = Marker(
        markerId: MarkerId("1"),
        position: LatLng(40.188526, 29.060965),
        infoWindow: InfoWindow(title: "Test Title", snippet: "Test Snippet"));
    //Kamerayı animasyon ile açısını değiştir.
    _controller
        ?.animateCamera(CameraUpdate.newLatLngZoom(_marker.position, 15));
    //Kamerayı move etme
    //_controller.moveCamera(CameraUpdate.newLatLngZoom(latLng, zoom))

    if (currentPosition == null) {
      return {_marker};
    } else {
      var currentMarker = Marker(
          markerId: MarkerId("Marker-Current"),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position:
              LatLng(currentPosition!.latitude, currentPosition!.longitude),
          infoWindow: InfoWindow(title: "Konumum"));
      return {_marker, currentMarker};
    }
  }

  void getLocation(BuildContext context) async {
    bool isServiceEnabled = false;
    LocationPermission permission;

    //Konum Servisleri Açık Mı Değil Mi ?
    /*isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lütfen konum servislerini aktif ediniz.')));
      return;
    }*/

    //Konum servisleri açık, uygulamanın yetkisi yok.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Uygulamaya konum servislerine erişim yetkisi veriniz.')));
        openAppSettings();
      }
    }

    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getLocation(context);
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
