import 'package:aplikasi_absensi/api/api_service.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/copy_right.dart';
import 'package:aplikasi_absensi/models/attendance_model.dart';
import 'package:aplikasi_absensi/models/attendance_stats_model.dart';
import 'package:aplikasi_absensi/view/check_in_page.dart';
import 'package:aplikasi_absensi/view/check_out_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  static const String id = "/dashboard_page";

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();
  String? _username;

  String _currentDate = '';
  AttendanceData? _todayAttendance;
  AttendanceStatsData? _attendanceStats;
  bool _isLoadingAttendance = true;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _initializeLocaleAndLoadData();
    _fetchTodayAttendanceStatus();
    _fetchAttendanceStats();
    _loadUsername();
  }

  /// Metode untuk memuat nama pengguna dari AuthService
  Future<void> _loadUsername() async {
    final username =
        await _authService
            .getUsername(); // Memanggil metode baru dari AuthService
    setState(() {
      _username = username; // Memperbarui state _username
    });
  }

  Future<void> _initializeLocaleAndLoadData() async {
    await initializeDateFormatting('id_ID', null);
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    setState(() {
      _currentDate = formatter.format(now);
    });
  }

  Future<void> _fetchTodayAttendanceStatus() async {
    setState(() => _isLoadingAttendance = true);
    try {
      final response = await _authService.fetchTodayAttendance();
      setState(() {
        _todayAttendance =
            response.data ??
            AttendanceData(
              id: 0,
              attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              status: 'Belum Absen',
              alasanIzin: response.message,
            );
      });
    } catch (e) {
      setState(() {
        _todayAttendance = AttendanceData(
          id: 0,
          attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          status: 'error_loading',
          alasanIzin: 'Gagal memuat status absensi: $e',
        );
      });
    } finally {
      setState(() => _isLoadingAttendance = false);
    }
  }

  Future<void> _fetchAttendanceStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final response = await _authService.fetchAttendanceStats();
      if (response.data != null) {
        setState(() => _attendanceStats = response.data);
      } else {
        if (!mounted) return;
        _showMessage(
          context,
          response.message ?? 'Gagal memuat statistik absensi.',
          color: Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        context,
        'Gagal memuat statistik absensi: $e',
        color: Colors.red,
      );
    } finally {
      setState(() => _isLoadingStats = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 18) return 'Selamat Siang';
    return 'Selamat Malam';
  }

  List<PieChartSectionData> _getPieChartSections(AttendanceStatsData stats) {
    final double total = stats.totalMasuk + stats.totalIzin.toDouble();
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '0%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ];
    }
    return [
      PieChartSectionData(
        color: Colors.green,
        value: (stats.totalMasuk / total) * 100,
        title: '${stats.totalMasuk} Masuk',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.blueGrey,
        value: (stats.totalIzin / total) * 100,
        title: '${stats.totalIzin} Izin',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildStatRow({
    required String title,
    required int count,
    required Color color,
    required int total,
  }) {
    double percent = total > 0 ? count / total : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: $count (${(percent * 100).toStringAsFixed(1)}%)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.gray88,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: Colors.grey.shade300,
          color: color,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutral,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()}, ${_username ?? 'Pengguna'}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColor.myblue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentDate,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColor.gray88,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, CheckInPage.id).then((
                          value,
                        ) {
                          if (value == true) {
                            return _fetchTodayAttendanceStatus();
                          }
                        });
                      },
                      label: const Text(
                        "CHECK IN",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, CheckOutPage.id).then((
                          value,
                        ) {
                          if (value == true) {
                            return _fetchTodayAttendanceStatus();
                          }
                        });
                      },
                      label: const Text(
                        "CHECK OUT",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 12),
              // Padding(
              //   padding: const EdgeInsets.all(4.0),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: 40,
              //     child: ElevatedButton.icon(
              //       onPressed: () async {
              //         final TextEditingController alasanController =
              //             TextEditingController();
              //         DateTime selectedDate = DateTime.now();
              //         final TextEditingController dateController =
              //             TextEditingController(
              //               text: DateFormat('dd-MM-yyyy').format(selectedDate),
              //             );
              //         await showDialog(
              //           context: context,
              //           builder:
              //               (context) => AlertDialog(
              //                 backgroundColor: Colors.white,
              //                 title: Text(
              //                   "Ajukan izin",
              //                   style: TextStyle(
              //                     color: AppColor.myblue,
              //                     fontWeight: FontWeight.bold,
              //                   ),
              //                 ),
              //                 content: Column(
              //                   mainAxisSize: MainAxisSize.min,
              //                   children: [
              //                     TextField(
              //                       controller: dateController,
              //                       readOnly: true,
              //                       decoration: const InputDecoration(
              //                         labelText: "Tanggal Izin",
              //                         suffixIcon: Icon(Icons.calendar_today),
              //                       ),
              //                       onTap: () async {
              //                         final picked = await showDatePicker(
              //                           context: context,
              //                           initialDate: selectedDate,
              //                           firstDate: DateTime(
              //                             DateTime.now().year - 1,
              //                           ),
              //                           lastDate: DateTime(
              //                             DateTime.now().year + 1,
              //                           ),
              //                         );
              //                         if (picked != null) {
              //                           selectedDate = picked;
              //                           dateController.text = DateFormat(
              //                             'yyyy-MM-dd',
              //                           ).format(picked);
              //                         }
              //                       },
              //                     ),
              //                     TextField(
              //                       controller: alasanController,
              //                       decoration: const InputDecoration(
              //                         hintText: "Masukkan alasan izin",
              //                       ),
              //                       maxLines: 3,
              //                     ),
              //                     const SizedBox(height: 12),
              //                   ],
              //                 ),
              //                 actions: [
              //                   TextButton(
              //                     onPressed: () => Navigator.pop(context),
              //                     child: Text(
              //                       "Batal",
              //                       style: TextStyle(color: AppColor.myblue),
              //                     ),
              //                   ),
              //                   TextButton(
              //                     onPressed: () async {
              //                       try {
              //                         final result = await _authService
              //                             .ajukanIzin(
              //                               alasanController.text,
              //                               dateController.text,
              //                             );
              //                         _fetchTodayAttendanceStatus();
              //                         _fetchAttendanceStats();
              //                         print(
              //                           "Izin berhasil diajukan: ${result.message}",
              //                         );
              //                         if (!mounted) return;
              //                         ScaffoldMessenger.of(
              //                           context,
              //                         ).showSnackBar(
              //                           SnackBar(content: Text(result.message)),
              //                         );
              //                         Navigator.pop(context);
              //                       } catch (e) {
              //                         print("Error mengajukan izin: $e");
              //                         if (!mounted) return;
              //                         ScaffoldMessenger.of(
              //                           context,
              //                         ).showSnackBar(
              //                           const SnackBar(
              //                             content: Text(
              //                               "Gagal mengajukan izin",
              //                             ),
              //                           ),
              //                         );
              //                         Navigator.pop(context);
              //                       }
              //                     },
              //                     child: Text(
              //                       "Kirim",
              //                       style: TextStyle(color: AppColor.myblue),
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //         );
              //       },
              //       label: const Text(
              //         "AJUKAN IZIN",
              //         style: TextStyle(color: Colors.white),
              //       ),
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.orange,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(30),
              //         ),
              //       ),
              // ),
              // ),
              // ),
              const SizedBox(height: 24),
              // Card Status Hari Ini
              Card(
                elevation: 8, // Meningkatkan elevasi
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppColor.myblue.withOpacity(0.2),
                    width: 1,
                  ), // Tambah border tipis
                ),
                shadowColor: AppColor.myblue.withOpacity(0.4), // Warna bayangan
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child:
                      _isLoadingAttendance
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Hari Ini',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.myblue,
                                ),
                              ),
                              const Divider(
                                height: 24,
                                thickness: 1,
                                color: Colors.grey,
                              ), // Perbaiki warna divider

                              if (_todayAttendance != null) ...[
                                _buildInfoRow(
                                  // Icons.event_available,
                                  'Status',
                                  _todayAttendance!.status,
                                ),
                                if (_todayAttendance!.checkInTime != null)
                                  _buildInfoRow(
                                    // Icons.login,
                                    'Check-in',
                                    _todayAttendance!.checkInTime!,
                                  ),
                                if (_todayAttendance!.checkOutTime != null)
                                  _buildInfoRow(
                                    // Icons.logout,
                                    'Check-out',
                                    _todayAttendance!.checkOutTime!,
                                  ),
                                if (_todayAttendance!.status.toLowerCase() ==
                                    'izin')
                                  _buildInfoRow(
                                    // Icons.info_outline,
                                    'Alasan',
                                    _todayAttendance!.alasanIzin ?? '-',
                                  ),
                              ] else
                                const Text(
                                  'Tidak ada data absensi hari ini.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Statistik Kehadiran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.myblue,
                ),
              ),
              const SizedBox(height: 12),
              // Card Statistik Kehadiran
              if (_isLoadingStats)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_attendanceStats != null)
                Card(
                  elevation: 8, // Meningkatkan elevasi
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppColor.myblue.withOpacity(0.2),
                      width: 1,
                    ), // Tambah border tipis
                  ),
                  shadowColor: AppColor.myblue.withOpacity(
                    0.4,
                  ), // Warna bayangan
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow(
                          title: 'Hadir',
                          count: _attendanceStats!.totalMasuk,
                          color: Colors.green,
                          total:
                              _attendanceStats!.totalMasuk +
                              _attendanceStats!.totalIzin,
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          title: 'Izin',
                          count: _attendanceStats!.totalIzin,
                          color: Colors.blueGrey,
                          total:
                              _attendanceStats!.totalMasuk +
                              _attendanceStats!.totalIzin,
                        ),
                        const SizedBox(height: 20),
                        AspectRatio(
                          aspectRatio: 1.3,
                          child: PieChart(
                            PieChartData(
                              sections: _getPieChartSections(_attendanceStats!),
                              centerSpaceRadius: 30,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const CopyrightWidget(
                appName: 'Endah F N', // Ganti dengan nama aplikasi Anda
                companyName: 'Si Absensi', // Ganti dengan nama perusahaan Anda
                textColor: Colors.grey, // Opsional: Sesuaikan warna teks
                fontSize: 10.0, // Opsional: Sesuaikan ukuran font
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon(icon, color: AppColor.myblue, size: 20), // Menambahkan ikon
          const SizedBox(width: 12), // Menambah jarak antara ikon dan teks
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColor.myblue,
            ), // Warna teks label
          ),
          const SizedBox(width: 8), // Menambah jarak antara label dan value
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: AppColor.gray88),
            ),
          ), // Warna teks value
        ],
      ),
    );
  }

  void _showMessage(
    BuildContext context,
    String message, {
    Color color = Colors.black,
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
