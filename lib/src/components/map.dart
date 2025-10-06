import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart' as rx;

class AruMap extends StatefulWidget {
  final Rx<AruMapLocation> currentLocation;
  final Rx<AruMapLocation> destination;
  // void onMapCreated(GoogleMapController)? onMapCreated;

  const AruMap({
    super.key, 
    required this.currentLocation, 
    required this.destination,
    // this.onMapCreated
  });

  @override
  AruMapState createState() => AruMapState();
}

class AruMapState extends State<AruMap> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  late AruMapLocation currentLocation;
  late AruMapLocation destination;

  @override
  void initState() {
    super.initState();
    final apiKey = String.fromEnvironment('GOOGLE_API_KEY');
    polylinePoints = PolylinePoints(apiKey: apiKey);
    currentLocation = widget.currentLocation.value;
    destination = widget.destination.value;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        zoom: 12,
        bearing: 30,
        tilt: 0,
        target: currentLocation.coordinates,
      ),
      compassEnabled: false,
      tiltGesturesEnabled: false,
      markers: _markers,
      polylines: _polylines,
      onMapCreated: onMapCreated,
    );
  }

  void onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    controller.moveCamera(CameraUpdate.newLatLngBounds(
      computeBounds([
        destination.coordinates, 
        currentLocation.coordinates
      ]), 
      70
    ));

    setMapPins();
    await setPolylines();

    widget.currentLocation.stream.listen((l) {
      updateMap(l);
    });

    widget.destination.stream.listen((l) {
      updateMap(l);
    });
  }

  void updateMap(AruMapLocation data) async {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == data.title);

      _markers.add(Marker(
        markerId: MarkerId(data.title),
        position: data.coordinates,
        icon: data.markerIcon
      ));
    });

    await setPolylines();
  }

  void setMapPins() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('currLocPin'),
        position: currentLocation.coordinates,
        // position: LatLng(6.568211261788388, 3.3671732968195087),
        icon: currentLocation.markerIcon,
        anchor: Offset(0.5, 0.5)
      ));

      _markers.add( Marker(
        markerId: MarkerId('dstPin'),
        position: destination.coordinates,
        icon: destination.markerIcon,
        anchor: Offset(0.5, 0.5)
      ));
    });
  }

  /*Future updateMapPin() async {
    final courierId = widget.shipment.to['_id'];
    List? courierCoords = await _userService.getCourierLocation(id: courierId);

    print('coords: $courierCoords');

    CameraPosition cPosition = CameraPosition(
        zoom: 14,
        tilt: 0,
        bearing: 30,
        target: LatLng(courierCoords![0], courierCoords[1]));

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'pkgPin');

      _markers.add(Marker(
          markerId: MarkerId('pkgPin'),
          position: LatLng(courierCoords[0], courierCoords[1]),
          icon: sourceIcon));
    });
  }*/

  setPolylines() async {
    polylineCoordinates.clear();
    _polylines.clear();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(
          currentLocation.coordinates.latitude,
          currentLocation.coordinates.longitude
        ),
        destination: PointLatLng(
          destination.coordinates.latitude,
          destination.coordinates.longitude
        ),
        mode: TravelMode.driving
      )
    );

    if (result.points.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
        width: 5,
        patterns: [PatternItem.dash(10), PatternItem.gap(10)],
        polylineId: PolylineId("poly"),
        color: colorPrimary,
        points: polylineCoordinates
      );

      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines.add(polyline);
    });
  }

  

  LatLngBounds computeBounds(List<LatLng> list) {
    assert(list.isNotEmpty);
    var firstLatLng = list.first;
    var s = firstLatLng.latitude,
        n = firstLatLng.latitude,
        w = firstLatLng.longitude,
        e = firstLatLng.longitude;
    for (var i = 1; i < list.length; i++) {
      var latlng = list[i];
      s = min(s, latlng.latitude);
      n = max(n, latlng.latitude);
      w = min(w, latlng.longitude);
      e = max(e, latlng.longitude);
    }
    return LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e));
  }
}

class AruMapLocation {
  late String title;
  LatLng coordinates = LatLng(0.0, 0.0);
  late String iconPath;
  late BitmapDescriptor markerIcon;

  Future init(String title, String iconPath) async {
    this.title = title;
    this.iconPath = iconPath;
    final Uint8List icon = await _getBytesFromAsset(iconPath, 100);
    markerIcon = BitmapDescriptor.bytes(icon);
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
  }
}