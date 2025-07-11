import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AruMap extends StatefulWidget {
  // final LatLng initialLocation;
  final Map request;

  const AruMap({
    super.key, 
    required this.request, 
  });

  @override
  AruMapState createState() => AruMapState();
}

class AruMapState extends State<AruMap> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  late BitmapDescriptor pickupIcon;
  late BitmapDescriptor dropoffIcon;

  late List pickupCoords = widget.request['pickupLocation']['coordinates'];
  late List dropoffCoords = widget.request['dropoffLocation']['coordinates'];

  late LatLng pickupLocation;
  late LatLng dropoffLocation;

  @override
  void initState() {
    super.initState();
    pickupLocation = LatLng(pickupCoords[1], pickupCoords[0]);
    dropoffLocation = LatLng(pickupCoords[1], pickupCoords[0]);
  }

  Future setSourceAndDestinationIcons() async {
    final Uint8List pickupMarkerIcon = await getBytesFromAsset('assets/images/pickup.png', 100);
    pickupIcon = BitmapDescriptor.bytes(pickupMarkerIcon);

    final Uint8List dropoffMarkerIcon = await getBytesFromAsset('assets/images/dropoff.png', 100);
    dropoffIcon = BitmapDescriptor.bytes(dropoffMarkerIcon);

    setMapPins();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        zoom: 12,
        bearing: 30,
        tilt: 0,
        target: pickupLocation,
      ),
      compassEnabled: false,
      tiltGesturesEnabled: false,
      markers: _markers,
      polylines: _polylines,
      onMapCreated: onMapCreated,
    );
  }

  void onMapCreated(GoogleMapController controller) async {
    controller.moveCamera(CameraUpdate.newLatLngBounds(
      computeBounds([dropoffLocation, pickupLocation]), 
      70
    ));

    _controller.complete(controller);
    await setSourceAndDestinationIcons();
    await setPolylines();

    await Future.delayed(Duration(seconds: 3));

    // updateMapPin();
  }

  void setMapPins() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('pickupPin'),
        position: pickupLocation,
        icon: pickupIcon
      ));
      _markers.add(Marker(
        markerId: MarkerId('dropoffPin'),
        position: dropoffLocation,
        icon: dropoffIcon
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
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: 'AIzaSyDB1OcmcWfuWBk_2xkGENRZ-D9Ud7tjVpg',
      request: PolylineRequest(
        origin: PointLatLng(pickupLocation.latitude, pickupLocation.longitude),
        destination: PointLatLng(dropoffLocation.latitude, dropoffLocation.longitude),
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
          points: polylineCoordinates);

      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines.add(polyline);
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
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