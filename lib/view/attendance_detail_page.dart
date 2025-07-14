// import 'package:flutter/material.dart';
// import 'package:aplikasi_absensi/constant/app_color.dart';
// import 'package:aplikasi_absensi/models/attendance_model.dart'; // Import AttendanceData
// import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps
// import 'package:intl/intl.dart'; // For date formatting

// class AttendanceDetailPage extends StatefulWidget {
//   final AttendanceData attendanceData;

//   const AttendanceDetailPage({super.key, required this.attendanceData});
//   static const String id = "/attendance_detail_page";

//   @override
//   State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
// }

// class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
//   late GoogleMapController mapController;
//   Set<Marker> markers = {};
//   LatLng? _initialPosition;

//   @override
//   void initState() {
//     super.initState();
//     _setInitialMapPosition();
//   }

//   void _setInitialMapPosition() {
//     // Tentukan posisi awal peta berdasarkan data check-in atau check-out
//     if (widget.attendanceData.checkInLat != null &&
//         widget.attendanceData.checkInLng != null) {
//       _initialPosition = LatLng(
//         widget.attendanceData.checkInLat!,
//         widget.attendanceData.checkInLng!,
//       );
//       _addMarker(
//         'checkInLocation',
//         _initialPosition!,
//         'Lokasi Absen Masuk',
//         'Waktu: ${widget.attendanceData.checkInTime ?? '-'}',
//       );
//     } else if (widget.attendanceData.checkOutLat != null &&
//         widget.attendanceData.checkOutLng != null) {
//       _initialPosition = LatLng(
//         widget.attendanceData.checkOutLat!,
//         widget.attendanceData.checkOutLng!,
//       );
//       _addMarker(
//         'checkOutLocation',
//         _initialPosition!,
//         'Lokasi Absen Pulang',
//         'Waktu: ${widget.attendanceData.checkOutTime ?? '-'}',
//       );
//     }
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   void _addMarker(String id, LatLng position, String title, String snippet) {
//     markers.add(
//       Marker(
//         markerId: MarkerId(id),
//         position: position,
//         infoWindow: InfoWindow(title: title, snippet: snippet),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final attendance = widget.attendanceData;

//     return Scaffold(
//       backgroundColor: AppColor.neutral,
//       appBar: AppBar(
//         title: const Text(
//           'Detail Absensi',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: AppColor.myblue2,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Tanggal Absensi: ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.parse(attendance.attendanceDate))}',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppColor.myblue,
//                       ),
//                     ),
//                     const Divider(height: 20),
//                     _buildInfoRow(
//                       'Status',
//                       attendance.status.toUpperCase(),
//                       attendance.status == 'masuk'
//                           ? Colors.green
//                           : attendance.status == 'pulang'
//                           ? AppColor.orange
//                           : Colors.blueGrey,
//                     ),
//                     _buildInfoRow('Waktu Masuk', attendance.checkInTime ?? '-'),
//                     _buildInfoRow(
//                       'Alamat Masuk',
//                       attendance.checkInAddress ?? '-',
//                     ),
//                     _buildInfoRow(
//                       'Waktu Pulang',
//                       attendance.checkOutTime ?? '-',
//                     ),
//                     _buildInfoRow(
//                       'Alamat Pulang',
//                       attendance.checkOutAddress ?? '-',
//                     ),
//                     if (attendance.alasanIzin != null &&
//                         attendance.alasanIzin!.isNotEmpty)
//                       _buildInfoRow('Alasan Izin', attendance.alasanIzin!),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Google Map Section
//             if (_initialPosition != null)
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 clipBehavior:
//                     Clip.antiAlias, // Penting untuk rounded corners pada map
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Text(
//                         'Lokasi Absensi',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: AppColor.myblue,
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 300, // Tinggi peta
//                       width: double.infinity,
//                       child: GoogleMap(
//                         onMapCreated: _onMapCreated,
//                         initialCameraPosition: CameraPosition(
//                           target: _initialPosition!,
//                           zoom: 15.0, // Zoom level
//                         ),
//                         markers: markers,
//                         myLocationButtonEnabled:
//                             false, // Sembunyikan tombol lokasi saya
//                         zoomControlsEnabled: true, // Tampilkan kontrol zoom
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             else
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     'Data lokasi tidak tersedia untuk absensi ini.',
//                     style: TextStyle(fontSize: 16, color: AppColor.gray88),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(
//     String label,
//     String value, [
//     Color valueColor = Colors.black87,
//   ]) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: AppColor.gray88,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: TextStyle(fontSize: 16, color: valueColor),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
