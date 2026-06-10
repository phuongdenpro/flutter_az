import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapTestScreen extends StatefulWidget {
  const GoogleMapTestScreen({super.key});

  @override
  State<GoogleMapTestScreen> createState() => _GoogleMapTestScreenState();
}

class _GoogleMapTestScreenState extends State<GoogleMapTestScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Position? _currentPosition;
  String _status = 'Đang tải vị trí...';

  static const LatLng _fixedDestination = LatLng(21.0278, 105.8342);
  static const CameraPosition _initialCamera = CameraPosition(
    target: _fixedDestination,
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _status = 'Vui lòng bật dịch vụ vị trí để xem bản đồ.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _status = 'Quyền vị trí bị từ chối vĩnh viễn. Xin cấp lại trong cài đặt.';
        });
        return;
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _status = 'Quyền vị trí bị từ chối. Không thể lấy vị trí hiện tại.';
        });
        return;
      }

      await _updateCurrentLocation();
    } catch (error) {
      setState(() {
        _status = 'Lỗi khi lấy vị trí: $error';
      });
    }
  }

  Future<void> _updateCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    );

    setState(() {
      _currentPosition = position;
      _status = 'Vị trí hiện tại: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_to_fixed_point'),
          color: Colors.blue,
          width: 5,
          points: [
            LatLng(position.latitude, position.longitude),
            _fixedDestination,
          ],
        ),
      );
    });

    await _moveCamera(LatLng(position.latitude, position.longitude));
  }

  Future<void> _moveCamera(LatLng target) async {
    final controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 15),
      ),
    );
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('tap_${position.latitude}_${position.longitude}'),
          position: position,
          infoWindow: const InfoWindow(
            title: 'Vị trí đã chọn',
            snippet: 'Bấm nút nổi để quay về vị trí hiện tại',
          ),
        ),
      );
    });
  }

  Future<void> _goToCurrentPosition() async {
    if (_currentPosition == null) {
      await _updateCurrentLocation();
      return;
    }

    await _moveCamera(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Test'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCamera,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            onTap: _onMapTap,
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_status, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _updateCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Cập nhật vị trí'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await _moveCamera(_fixedDestination);
                          },
                          icon: const Icon(Icons.location_pin),
                          label: const Text('Điểm cố định'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCurrentPosition,
        label: const Text('Về vị trí'),
        icon: const Icon(Icons.gps_fixed),
      ),
    );
  }
}
