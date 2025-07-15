import 'dart:async';

import 'package:aplikasi_absensi/api/api_service.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});
  static const String id = "/check_in_page";

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final AuthService _authService = AuthService();
  late GoogleMapController _mapController;
  bool _isLoading = false;
  String _statusMessage = 'Sedang mengambil lokasi...';
  Color _messageColor = Colors.black;
  Position? _currentPosition;

  static const LatLng _ppkdLocation = LatLng(
    -6.2109,
    106.8129,
  ); // PPKD Jakarta Pusat

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage('Layanan lokasi nonaktif.', color: Colors.red);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _showMessage('Izin lokasi ditolak.', color: Colors.red);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);
    } catch (e) {
      _showMessage('Gagal mendapatkan lokasi: $e', color: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkIn() async {
    if (_currentPosition == null) return;
    setState(() => _isLoading = true);

    try {
      // Hitung jarak ke titik pusat (PPKD)
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _ppkdLocation.latitude,
        _ppkdLocation.longitude,
      );

      if (distance > 100) {
        _showMessage(
          'Anda berada di luar area absen (> ${distance.toStringAsFixed(1)} meter).',
          color: Colors.red,
        );
        setState(() => _isLoading = false);
        return;
      }

      // Ambil alamat dari koordinat
      String address = 'Alamat tidak diketahui';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          address = '${place.street}, ${place.locality}';
        }
      } catch (_) {}

      final now = DateTime.now();
      final response = await _authService.checkInAttendance(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: address,
        attendanceDate: DateFormat('yyyy-MM-dd').format(now),
        checkIn: DateFormat('HH:mm').format(now),
      );

      if (response.data != null) {
        _showMessage(
          response.message ?? 'Berhasil absen masuk.',
          color: Colors.green,
        );
        if (mounted) Navigator.pop(context, true);
      } else {
        _showMessage(
          response.message ?? 'Gagal absen masuk.',
          color: Colors.red,
        );
      }
    } catch (e) {
      _showMessage('Error saat absen: $e', color: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {Color color = Colors.black}) {
    setState(() {
      _statusMessage = message;
      _messageColor = color;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutral,
      appBar: AppBar(
        title: const Text(
          'Absen Masuk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.myblue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.myblue, AppColor.myblue1],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body:
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (controller) => _mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: 17,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: {
                      Marker(
                        markerId: const MarkerId('current'),
                        position: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        infoWindow: const InfoWindow(title: 'Lokasi Anda'),
                      ),
                      Marker(
                        markerId: const MarkerId('ppkd'),
                        position: _ppkdLocation,
                        infoWindow: const InfoWindow(
                          title: 'PPKD Jakarta Pusat',
                        ),
                      ),
                    },
                    circles: {
                      Circle(
                        circleId: const CircleId("ppkd_radius"),
                        center: _ppkdLocation,
                        radius: 100,
                        fillColor: Colors.blue.withOpacity(0.2),
                        strokeColor: Colors.blueAccent,
                        strokeWidth: 2,
                      ),
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _checkIn,
                      // icon: const Icon(Icons.login, color: Colors.white),
                      label: const Text(
                        "Absen Masuk",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.myblue,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
