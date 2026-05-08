import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:wujidt/features/home/models/scan_item_model.dart';
import 'package:wujidt/features/home/widgets/map_marker.dart';

class BrowseController extends ChangeNotifier {
  static const String _apiKey = "AIzaSyA156WdigDXIUp0UayqtZVoqa8LJBUO7sY";
  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);

  GoogleMapController? mapController;

  List<ScanItemModel> browseItems = [];
  Set<Marker> markers = {};
  ScanItemModel? selectedItem;
  LatLng currentLocation = _defaultLocation;
  Set<Polyline> polylines = {};
  String travelInfo = "";

  int _routeRequestToken = 0;
  final Map<String, BitmapDescriptor> _markerIconCache = {};
  late final PolylinePoints _polylinePoints;

  BrowseController() {
    _polylinePoints = PolylinePoints(apiKey: _apiKey);
  }


  Future<void> getCurrentLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    currentLocation = LatLng(position.latitude, position.longitude);
    notifyListeners();

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(currentLocation, 15),
    );
  }


  Future<void> onDestinationSelected(LatLng dest) async {
    final int myToken = ++_routeRequestToken;

    polylines = {};
    travelInfo = "";
    notifyListeners();

    await Future.wait([
      _fetchPolyline(dest, myToken),
      _fetchDirectionsInfo(dest, myToken),
    ]);
  }

  Future<void> _fetchPolyline(LatLng dest, int token) async {
    try {
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        // ignore: deprecated_member_use
        request: PolylineRequest(
          origin: PointLatLng(
            currentLocation.latitude,
            currentLocation.longitude,
          ),
          destination: PointLatLng(dest.latitude, dest.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (token != _routeRequestToken) return;
      if (result.points.isEmpty) return;

      final coords =
          result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();

      polylines = {
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue,
          width: 5,
          points: coords,
        ),
      };
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _fetchDirectionsInfo(LatLng dest, int token) async {
    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=${currentLocation.latitude},${currentLocation.longitude}"
        "&destination=${dest.latitude},${dest.longitude}"
        "&mode=driving"
        "&language=en"
        "&key=$_apiKey",
      );

      final response = await http.get(url);
      if (token != _routeRequestToken) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "OK" && (data["routes"] as List).isNotEmpty) {
          final leg = data["routes"][0]["legs"][0];
          travelInfo =
              "Distance: ${leg["distance"]["text"]} | Duration: ${leg["duration"]["text"]}";
          notifyListeners();
          return;
        }
      }
      _fallbackTravelInfo(dest, token);
    } catch (_) {
      _fallbackTravelInfo(dest, token);
    }
  }

  void _fallbackTravelInfo(LatLng dest, int token) {
    if (token != _routeRequestToken) return;

    final double distanceInMeters = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      dest.latitude,
      dest.longitude,
    );
    final double km = distanceInMeters / 1000;
    final double durationMinutes = (km / 40) * 60;

    travelInfo =
        "Distance: ~${km.toStringAsFixed(1)} km | Duration: ~${durationMinutes.toInt()} min (approx)";
    notifyListeners();
  }


  void handleMapTap(LatLng latLng) {
    selectedItem = null;

    final bool hasRedMarker =
        markers.any((m) => m.markerId.value == "tapped_location");

    if (hasRedMarker) {
      markers =
          markers.where((m) => m.markerId.value != "tapped_location").toSet();
      polylines = {};
      travelInfo = "";
      ++_routeRequestToken;
      notifyListeners();
    } else {
      updateMarkers(tappedPoint: latLng);
      onDestinationSelected(latLng);
    }
  }


  Future<void> updateMarkers({LatLng? tappedPoint}) async {
    if (tappedPoint != null) {
      markers = {
        ...markers.where((m) => m.markerId.value != "tapped_location"),
        Marker(
          markerId: const MarkerId("tapped_location"),
          position: tappedPoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
      notifyListeners();
    }

    final validItems = browseItems
        .where((item) => item.latitude != null && item.longitude != null)
        .toList();

    if (validItems.isEmpty) return;

    bool isItemSelected(ScanItemModel item) => selectedItem?.id == item.id;

    final iconEntries = await Future.wait(
      validItems.map((item) async {
        final cacheKey = "${item.id}_${isItemSelected(item)}";
        final cached = _markerIconCache[cacheKey];
        if (cached != null) return MapEntry(item, cached);

        final icon = await MapMarker.buildCustomMarker(
          item: item,
          isSelected: isItemSelected(item),
        );
        _markerIconCache[cacheKey] = icon;
        return MapEntry(item, icon);
      }),
    );

    final Set<Marker> newMarkers = {
      for (final entry in iconEntries)
        Marker(
          markerId: MarkerId(entry.key.id.toString()),
          position: LatLng(entry.key.latitude!, entry.key.longitude!),
          icon: entry.value,
          onTap: () => _onMarkerTap(entry.key),
        ),
    };

    if (tappedPoint != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId("tapped_location"),
          position: tappedPoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    markers = newMarkers;
    notifyListeners();
  }

  void _onMarkerTap(ScanItemModel item) {
    _markerIconCache.removeWhere((key, _) =>
        key.startsWith("${item.id}_") ||
        (selectedItem != null && key.startsWith("${selectedItem!.id}_")));

    selectedItem = item;
    notifyListeners();

    onDestinationSelected(LatLng(item.latitude!, item.longitude!));

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(item.latitude!, item.longitude!),
        16,
      ),
    );

    updateMarkers();
  }


  void resetMapState() {
    selectedItem = null;
    travelInfo = "";
    polylines = {};
    _markerIconCache.clear();
    notifyListeners();
  }

  void resetBrowseMode() {
    selectedItem = null;
    travelInfo = "";
    polylines = {};
    notifyListeners();
  }
}