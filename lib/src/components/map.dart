import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AruMap extends StatefulWidget {
  // final LatLng initialLocation;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(GoogleMapController controller) onMapCreated;
  final String? mapStyle;

  const AruMap({
    super.key, 
    // required this.initialLocation, 
    this.markers = const {}, 
    this.polylines = const {},
    required this.onMapCreated, 
    this.mapStyle
  });

  @override
  AruMapState createState() => AruMapState();
}

class AruMapState extends State<AruMap> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: widget.onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(6.526198337822965, 3.365657591473232),
        zoom: 11
      )
    );
  }
}