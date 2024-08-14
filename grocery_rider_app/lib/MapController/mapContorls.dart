import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';

MapController createMapController() {
  return MapController(
    initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
    areaLimit: BoundingBox(
      east: 10.4922941,
      north: 47.8084648,
      south: 45.817995,
      west: 5.9559113,
    ),
  );
}

Future<void> addMarkerAtCurrentPosition(MapController mapController) async {
  try {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    GeoPoint currentPosition =
        GeoPoint(latitude: position.latitude, longitude: position.longitude);

    await mapController.addMarker(
      currentPosition,
      markerIcon: MarkerIcon(
        icon: Icon(
          Icons.location_on,
          color: Colors.red,
          size: 48,
        ),
      ),
    );
  } catch (e) {
    print("Error getting current location: $e");
  }
}

void zoomIn(MapController mapController) {
  mapController.zoomIn();
}

void zoomOut(MapController mapController) {
  mapController.zoomOut();
}
