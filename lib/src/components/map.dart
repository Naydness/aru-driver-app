import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:aru/src/constants.dart';
import 'package:aru/src/views/ride.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AruMap extends StatefulWidget {
  final Rx<AruMapLocation> currentLocation;
  final Rx<AruMapLocation> destination;
  final Rx<OrderState> orderState;

  const AruMap({
    super.key, 
    required this.currentLocation, 
    required this.destination,
    required this.orderState
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
  late ValueNotifier<Set<Polyline>> _polylineNotifier;
  String? style;

  late AruMapLocation currentLocation;
  late AruMapLocation destination;

  @override
  void initState() {
    super.initState();

    _polylineNotifier = ValueNotifier<Set<Polyline>>({});
    currentLocation = widget.currentLocation.value;
    widget.currentLocation.stream.listen((location) async {
      print('Current location change...');
      currentLocation = location;
      await setPolylines();
      updateMarkers();
    });

    destination = widget.destination.value;
    widget.destination.stream.listen((location) async {
      print('Destination change...');
      destination = location;
      await setPolylines();
      updateMarkers();
    });

    print('Current: ${currentLocation.coordinates}');
    print('Destination: ${destination.coordinates}');

    widget.orderState.listen((state) async {
      print('OrderState change...');

      switch (state) {
        case OrderState.rideAccepted:
        case OrderState.rideStarted:
          final c = await _controller.future;
          await c.moveCamera(CameraUpdate.newLatLngBounds(
            computeBounds([
              polylineCoordinates.last,
              polylineCoordinates.first
            ]), 
            70
          ));
          break;
        default:
      }
    });

    setMapStyle();
  }

  void setMapStyle() async {
    rootBundle.loadString('assets/map_theme.json').then((v) {
      setState(() {
        style = v;
      });
    });
  }

  void initMapObjects(OrderState orderState) async {
    await setPolylines();
    updateMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _polylineNotifier, 
      builder: (context, polylines, _) {
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            zoom: 12,
            bearing: 30,
            tilt: 0,
            target: currentLocation.coordinates,
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * .5),
          compassEnabled: false,
          tiltGesturesEnabled: false,
          markers: _markers,
          polylines: polylines,
          style: style,
          zoomControlsEnabled: false,
          onMapCreated: onMapCreated,
        );
      }
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

    initMapObjects(widget.orderState.value);
  }

  void updateMarkers() async {
    if (polylineCoordinates.isNotEmpty) {
      setState(() {
        _markers.clear();

        _markers.add(
          Marker(
            markerId: MarkerId('currLocPin'),
            position: polylineCoordinates.first,
            icon: currentLocation.markerIcon,
            anchor: Offset(0.5, 0.5)
          )
        );

        _markers.add(
          Marker(
            markerId: MarkerId('dstPin'),
            position: polylineCoordinates.last,
            icon: destination.markerIcon,
            anchor: Offset(0.5, 0.5)
          )
        );
      });
    }
  }

  void setMarkers() {
    if (polylineCoordinates.isNotEmpty) {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId('currLocPin'),
          position: polylineCoordinates.first,
          icon: currentLocation.markerIcon,
          anchor: Offset(0.5, 0.5)
        ));

        _markers.add( Marker(
          markerId: MarkerId('dstPin'),
          position: polylineCoordinates.last,
          icon: destination.markerIcon,
          anchor: Offset(0.5, 0.5)
        ));
      });
    }
  }

  Future<void> setPolylines() async {
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
      ),
      googleApiKey: 'AIzaSyDB1OcmcWfuWBk_2xkGENRZ-D9Ud7tjVpg'
    );

    if (result.points.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }


    Polyline polyline = Polyline(
      width: 5,
      polylineId: PolylineId("poly"),
      color: colorPrimary,
      points: polylineCoordinates
    );

    _polylineNotifier.value = {polyline};
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