// import 'package:flutter/material.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:geolocator/geolocator.dart';

// MapController createMapController() {
//   return MapController(
//     initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
//     areaLimit: BoundingBox(
//       east: 10.4922941,
//       north: 47.8084648,
//       south: 45.817995,
//       west: 5.9559113,
//     ),
//   );
// }

// Future<void> addMarkerAtCurrentPosition(MapController mapController) async {
//   try {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     GeoPoint currentPosition =
//         GeoPoint(latitude: position.latitude, longitude: position.longitude);

//     await mapController.addMarker(
//       currentPosition,
//       markerIcon: MarkerIcon(
//         icon: Icon(
//           Icons.location_on,
//           color: Colors.red,
//           size: 48,
//         ),
//       ),
//     );
//   } catch (e) {
//     print("Error getting current location: $e");
//   }
// }

// void zoomIn(MapController mapController) {
//   mapController.zoomIn();
// }

// void zoomOut(MapController mapController) {
//   mapController.zoomOut();
// }
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

Future<void> addMarkerAndPolyline(MapController mapController) async {
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

    // Define a destination point (replace with your desired coordinates)
    GeoPoint destination = GeoPoint(latitude: 26.6232, longitude: 87.9678);

    // Add a marker for the destination
    await mapController.addMarker(
      destination,
      markerIcon: MarkerIcon(
        icon: Icon(
          Icons.flag,
          color: Colors.green,
          size: 48,
        ),
      ),
    );

    // Draw a polyline between the current position and the destination
    await addPolyline(mapController, currentPosition, destination);

  } catch (e) {
    print("Error getting current location or drawing polyline: $e");
  }
}

Future<void> addPolyline(MapController mapController, GeoPoint start, GeoPoint end) async {
  try {
    final roadInfo = await mapController.drawRoad(
      start,
      end,
      roadType: RoadType.car,
      roadOption: const RoadOption(
        roadWidth: 10,
        roadColor: Colors.blue,
      ),
    );
    print("Road length: ${roadInfo.distance}km");
    print("Road duration: ${roadInfo.duration}sec");
  } catch (e) {
    print("Error drawing road: $e");
  }
}

void zoomIn(MapController mapController) {
  mapController.zoomIn();
}

void zoomOut(MapController mapController) {
  mapController.zoomOut();
}