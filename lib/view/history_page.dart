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
        title: const Text(
          'Riwayat Kehadiran',
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

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          item.status == 'masuk'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                      child: Icon(
                        item.status == 'masuk'
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color:
                            item.status == 'masuk'
                                ? Colors.green
                                : Colors.orange,
                      ),
                    ),
                    title: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${item.status}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          if (item.status == 'izin' && item.alasanIzin != null)
                            Text(
                              'Alasan: ${item.alasanIzin}',
                              style: const TextStyle(fontSize: 14),
                            )
                          else
                            Text(
                              'Check In: ${item.checkInTime ?? '-'} | Check Out: ${item.checkOutTime ?? '-'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                        ],
                      ),
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
