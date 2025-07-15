import 'dart:async';

import 'package:aplikasi_absensi/api/api_service.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({super.key});
  static const String id = "/check_out_page";

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  final AuthService _authService = AuthService();
  late GoogleMapController _mapController;
  bool _isLoading = false;
  String _statusMessage = 'Sedang mengambil lokasi...';
  Color _messageColor = Colors.black;
  Position? _currentPosition;

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

  Future<void> _checkOut() async {
    if (_currentPosition == null) return;
    setState(() => _isLoading = true);

    try {
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
      final response = await _authService.checkOutAttendance(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: address,
        attendanceDate: DateFormat('yyyy-MM-dd').format(now),
        checkOut: DateFormat('HH:mm').format(now),
      );

      if (response.data != null) {
        _showMessage(
          response.message ?? 'Berhasil absen pulang.',
          color: Colors.green,
        );
        if (mounted) Navigator.pop(context, true);
      } else {
        _showMessage(
          response.message ?? 'Gagal absen pulang.',
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
          'Absen Pulang',
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
                      zoom: 16,
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
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _checkOut,
                      label: const Text(
                        "Absen Pulang",
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
