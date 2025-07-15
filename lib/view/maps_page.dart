import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController _mapController;

  static const LatLng _absenLocation = LatLng(
    -6.2088,
    106.8456,
  ); // Jakarta Pusat

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      final result = await Permission.location.request();
      if (!result.isGranted) {
        _showMessage("Izin lokasi diperlukan untuk menampilkan peta.");
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutral,
      appBar: AppBar(
        title: const Text(
          'Lokasi Absen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.myblue,
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
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _absenLocation,
              zoom: 15.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId('absenLocation'),
                position: _absenLocation,
                infoWindow: const InfoWindow(
                  title: 'Titik Absen',
                  snippet: 'Kantor Pusat',
                ),
              ),
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              label: const Text(
                "Absen Sekarang",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.myblue,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _showMessage("Absensi berhasil dicatat!");
              },
            ),
          ),
        ],
      ),
    );
  }
}
