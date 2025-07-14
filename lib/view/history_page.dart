import 'package:aplikasi_absensi/api/api_service.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/models/history_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  static const String id = "/history_page";

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<HistoryData>> _futureHistory;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _futureHistory = _authService.fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutral,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Riwayat Kehadiran',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.myblue,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: FutureBuilder<List<HistoryData>>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat riwayat: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data kehadiran.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            final history = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final formattedDate = DateFormat(
                  'EEEE, dd MMMM yyyy',
                  'id_ID',
                ).format(DateTime.parse(item.attendanceDate));

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(
                      item.status == 'masuk' ? Icons.check_circle : Icons.info,
                      color:
                          item.status == 'masuk' ? Colors.green : Colors.orange,
                    ),
                    title: Text(
                      formattedDate,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${item.status}'),
                        if (item.status == 'izin' && item.alasanIzin != null)
                          Text('Alasan: ${item.alasanIzin}')
                        else
                          Text(
                            'Check In: ${item.checkInTime ?? '-'} | Check Out: ${item.checkOutTime ?? '-'}',
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// import 'package:aplikasi_absensi/constant/app_color.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class HistoryPage extends StatefulWidget {
//   const HistoryPage({super.key});

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   // Contoh data dummy
//   final List<Map<String, dynamic>> history = [
//     {
//       'date': DateTime.now().subtract(const Duration(days: 0)),
//       'status': 'Masuk',
//       'time': '08:05',
//     },
//     {
//       'date': DateTime.now().subtract(const Duration(days: 1)),
//       'status': 'Izin',
//       'time': '-',
//     },
//     {
//       'date': DateTime.now().subtract(const Duration(days: 2)),
//       'status': 'Masuk',
//       'time': '08:12',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.neutral,
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text(
//           'Riwayat Kehadiran',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: AppColor.myblue,
//         foregroundColor: Colors.white,
//         elevation: 0.5,
//       ),
//       body:
//           history.isEmpty
//               ? const Center(
//                 child: Text(
//                   'Belum ada data kehadiran.',
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               )
//               : ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: history.length,
//                 itemBuilder: (context, index) {
//                   final item = history[index];
//                   final formattedDate = DateFormat(
//                     'EEEE, dd MMMM yyyy',
//                     'id_ID',
//                   ).format(item['date']);

//                   return Card(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 2,
//                     child: ListTile(
//                       leading: Icon(
//                         item['status'] == 'Masuk'
//                             ? Icons.check_circle
//                             : Icons.info,
//                         color:
//                             item['status'] == 'Masuk'
//                                 ? Colors.green
//                                 : Colors.orange,
//                       ),
//                       title: Text(
//                         formattedDate,
//                         style: const TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                       subtitle: Text('Status: ${item['status']}'),
//                       trailing: Text(item['time']),
//                     ),
//                   );
//                 },
//               ),
//     );
//   }
// }
