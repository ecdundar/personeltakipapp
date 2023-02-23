import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  Set<Marker> _markers = new Set<Marker>();
  Set<Polyline> _polylines = new Set<Polyline>();

  Future<Set<Marker>> getMarkers() async {
    var _marker = Marker(
        markerId: MarkerId("1"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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
          icon: await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(150, 150)),
              "lib/assets/images/marker.png"),
          position:
              LatLng(currentPosition!.latitude, currentPosition!.longitude),
          infoWindow: InfoWindow(title: "Konumum"));
      return {_marker, currentMarker};
    }
  }

  Future<Set<Polyline>> getPolylines() async {
    if (_markers.length > 1) {
      var _first = _markers.first;
      var _last = _markers.last;

      var points = PolylinePoints();

      //Google Direactions Api üzerinden iki nokta arası route bilgisini alıyoruz.
      var result = await points.getRouteBetweenCoordinates(
          "AIzaSyDjJ8qPokjrMQ8avViylX4ke9skhyRzHmY",
          PointLatLng(_first.position.latitude, _first.position.longitude),
          PointLatLng(_last.position.latitude, _last.position.longitude));

      Map<PolylineId, Polyline> polylines = {};
      List<LatLng> polylineCoordinates = [];

      if (result.points.isNotEmpty) {
        result.points.forEach((p) {
          polylineCoordinates.add(LatLng(p.latitude, p.longitude));
        });
        var id = PolylineId('map');
        polylines[id] = Polyline(
            polylineId: id,
            color: Colors.red,
            points: polylineCoordinates,
            width: 3);
      }

      return Set<Polyline>.of(polylines.values);
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

    _markers = await getMarkers();
    _polylines = await getPolylines();
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
        markers: _markers,
        polylines: _polylines,
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
