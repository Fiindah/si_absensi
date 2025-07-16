import 'package:aplikasi_absensi/api/api_service.dart';
import 'package:aplikasi_absensi/api/endpoint.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/helper/share_pref.dart';
import 'package:aplikasi_absensi/models/profile_model.dart';
import 'package:aplikasi_absensi/view/auth_page/login_page.dart';
import 'package:aplikasi_absensi/view/profile_page/edit_profile_page.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const String id = "/profile_page";

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileData? _userProfile;
  bool _isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _authService.fetchUserProfile();
      if (response.data != null) {
        setState(() {
          _userProfile = response.data;
        });
      } else {
        _showMessage(context, response.message, color: Colors.red);
      }
    } catch (e) {
      _showMessage(context, 'Gagal memuat profil: $e', color: Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    Color color = Colors.black,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: color,
      ),
    );
  }

  String _formatGender(String? genderCode) {
    if (genderCode == null) return '-';
    switch (genderCode.toUpperCase()) {
      case 'L':
        return 'Laki-laki';
      case 'P':
        return 'Perempuan';
      default:
        return genderCode;
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    debugPrint('Menampilkan dialog konfirmasi logout.');
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Konfirmasi Logout',
            style: TextStyle(color: AppColor.myblue),
          ),
          content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColor.myblue),
              ),
              onPressed: () {
                debugPrint('Logout dibatalkan.');
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                debugPrint('Logout dikonfirmasi. Menutup dialog...');
                Navigator.of(context).pop();
                await _performLogout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    debugPrint('_performLogout: Memulai proses logout...');
    try {
      debugPrint('_performLogout: Memanggil _authService.logout()...');
      final bool loggedOut = await _authService.logout();
      debugPrint(
        '_performLogout: _authService.logout() selesai. Hasil: $loggedOut',
      );

      await SharedPreferencesUtil.clearAllData();
      debugPrint('_performLogout: SharedPreferences telah dibersihkan.');

      if (loggedOut) {
        _showMessage(context, 'Berhasil logout!', color: Colors.green);
        debugPrint(
          '_performLogout: Logout berhasil. Navigasi ke halaman login...',
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginPage.id,
          (route) => false,
        );
      } else {
        _showMessage(context, 'Gagal logout.', color: Colors.red);
        debugPrint('_performLogout: Logout gagal (loggedOut == false).');
      }
    } catch (e) {
      _showMessage(
        context,
        'Terjadi kesalahan saat logout: $e',
        color: Colors.red,
      );
      debugPrint('_performLogout: Exception saat logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutral,
      appBar: AppBar(
        title: const Text(
          'Profil Pengguna',
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadUserProfile,
                color: AppColor.myblue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: 24),
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColor.myblue,
                            backgroundImage:
                                _userProfile?.profilePhoto != null &&
                                        _userProfile!.profilePhoto!.isNotEmpty
                                    ? NetworkImage(
                                          _userProfile!.profilePhoto!
                                                  .startsWith('http')
                                              ? _userProfile!.profilePhoto!
                                              : '${Endpoint.baseUrl}/public/${_userProfile!.profilePhoto!}',
                                        )
                                        as ImageProvider<Object>
                                    : const AssetImage(
                                      'assets/images/default_profile.png',
                                    ),
                            onBackgroundImageError: (exception, stackTrace) {
                              debugPrint('Error loading image: $exception');
                            },
                            child:
                                _userProfile?.profilePhoto == null ||
                                        _userProfile!.profilePhoto!.isEmpty
                                    ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _userProfile?.name ?? 'Nama Pengguna',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColor.myblue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _userProfile?.email ?? 'email@example.com',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // User Information Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoSectionTitle('Informasi Pribadi'),

                                _buildDivider(),
                                _buildInfoRow(
                                  Icons.person_outline,
                                  'Nama',
                                  _userProfile?.name ?? '-',
                                ),
                                _buildDivider(),
                                _buildInfoRow(
                                  Icons.email_outlined, // Changed icon
                                  'Email',
                                  _userProfile?.email ?? '-',
                                ),
                                _buildDivider(),

                                _buildDivider(),
                                _buildInfoRow(
                                  Icons.wc_outlined, // Changed icon
                                  'Jenis Kelamin',
                                  _formatGender(_userProfile?.jenisKelamin),
                                ),
                                _buildDivider(),

                                const SizedBox(height: 20),
                                _buildInfoSectionTitle('Informasi Akademik'),
                                _buildInfoColumn(
                                  Icons.group_outlined, // Changed icon
                                  'Batch :',
                                  _userProfile?.batchKe ?? '-',
                                ),
                                _buildDivider(),
                                _buildInfoColumn(
                                  Icons.school_outlined, // Changed icon
                                  'Training :',
                                  _userProfile?.trainingTitle ?? '-',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            _buildActionButton(
                              label: "Ubah Profil",
                              icon: Icons.edit,
                              color: AppColor.myblue,
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const EditProfilePage(),
                                  ),
                                );
                                if (result == true) {
                                  _loadUserProfile();
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildActionButton(
                              label: "Logout",
                              icon: Icons.logout,
                              color: Colors.red,
                              onPressed: _showLogoutConfirmationDialog,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
      ), // Increased vertical padding
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align to start for multi-line values
        children: [
          Icon(icon, color: AppColor.myblue, size: 26), // Slightly larger icon
          const SizedBox(width: 20), // Increased spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15, // Slightly larger label font
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6), // Increased spacing
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17, // Slightly larger value font
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
      ), // Increased vertical padding
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align to start for multi-line values
        children: [
          Icon(icon, color: AppColor.myblue, size: 26), // Slightly larger icon
          const SizedBox(width: 20), // Increased spacing
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16, // Slightly larger label font
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 6), // Increased spacing
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16, // Slightly larger value font
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0, top: 5.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColor.myblue,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade200,
      indent: 45, // Indent to align with text
      endIndent: 10,
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

// import 'package:aplikasi_absensi/api/api_service.dart';
// import 'package:aplikasi_absensi/api/endpoint.dart';
// import 'package:aplikasi_absensi/constant/app_color.dart';
// import 'package:aplikasi_absensi/helper/share_pref.dart';
// import 'package:aplikasi_absensi/models/profile_model.dart';
// import 'package:aplikasi_absensi/view/auth_page/login_page.dart'; // Import LoginPage untuk ID rute
// import 'package:aplikasi_absensi/view/profile_page/edit_profile_page.dart';
// import 'package:flutter/material.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//   static const String id = "/profile_page";

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   ProfileData? _userProfile;
//   bool _isLoading = true;
//   final AuthService _authService = AuthService();

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   Future<void> _loadUserProfile() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final response = await _authService.fetchUserProfile();
//       if (response.data != null) {
//         setState(() {
//           _userProfile = response.data;
//         });
//       } else {
//         _showMessage(context, response.message, color: Colors.red);
//       }
//     } catch (e) {
//       _showMessage(context, 'Gagal memuat profil: $e', color: Colors.red);
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showMessage(
//     BuildContext context,
//     String message, {
//     Color color = Colors.black,
//   }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 3),
//         backgroundColor: color,
//       ),
//     );
//   }

//   String _formatGender(String? genderCode) {
//     if (genderCode == null) return '-';
//     switch (genderCode.toUpperCase()) {
//       case 'L':
//         return 'Laki-laki';
//       case 'P':
//         return 'Perempuan';
//       default:
//         return genderCode;
//     }
//   }

//   // Fungsi untuk menampilkan dialog konfirmasi logout
//   Future<void> _showLogoutConfirmationDialog() async {
//     debugPrint('Menampilkan dialog konfirmasi logout.');
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text(
//             'Konfirmasi Logout',
//             style: TextStyle(color: AppColor.myblue),
//           ),
//           content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text(
//                 'Batal',
//                 style: TextStyle(color: AppColor.myblue),
//               ),
//               onPressed: () {
//                 debugPrint('Logout dibatalkan.');
//                 Navigator.of(context).pop();
//               },
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               child: const Text(
//                 'Logout',
//                 style: TextStyle(color: Colors.white),
//               ),
//               onPressed: () async {
//                 debugPrint('Logout dikonfirmasi. Menutup dialog...');
//                 Navigator.of(context).pop();
//                 await _performLogout();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Fungsi terpisah untuk melakukan proses logout
//   Future<void> _performLogout() async {
//     debugPrint('_performLogout: Memulai proses logout...');
//     try {
//       debugPrint('_performLogout: Memanggil _authService.logout()...');
//       final bool loggedOut = await _authService.logout();
//       debugPrint(
//         '_performLogout: _authService.logout() selesai. Hasil: $loggedOut',
//       );

//       // Hapus data lokal dari SharedPreferences
//       await SharedPreferencesUtil.clearAllData();
//       debugPrint('_performLogout: SharedPreferences telah dibersihkan.');

//       if (loggedOut) {
//         _showMessage(context, 'Berhasil logout!', color: Colors.green);
//         debugPrint(
//           '_performLogout: Logout berhasil. Navigasi ke halaman login...',
//         );
//         Navigator.pushNamedAndRemoveUntil(
//           context,
//           LoginPage.id,
//           (route) => false,
//         );
//       } else {
//         _showMessage(context, 'Gagal logout.', color: Colors.red);
//         debugPrint('_performLogout: Logout gagal (loggedOut == false).');
//       }
//     } catch (e) {
//       _showMessage(
//         context,
//         'Terjadi kesalahan saat logout: $e',
//         color: Colors.red,
//       );
//       debugPrint('_performLogout: Exception saat logout: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.neutral,
//       appBar: AppBar(
//         title: const Text(
//           'Profil Pengguna',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: AppColor.myblue,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Center(
//                       child: CircleAvatar(
//                         radius: 60,
//                         backgroundImage:
//                             _userProfile?.profilePhoto != null &&
//                                     _userProfile!.profilePhoto!.isNotEmpty
//                                 ? NetworkImage(
//                                       _userProfile!.profilePhoto!.startsWith(
//                                             'http',
//                                           )
//                                           ? _userProfile!.profilePhoto!
//                                           : '${Endpoint.baseUrl}/public/${_userProfile!.profilePhoto!}',
//                                     )
//                                     as ImageProvider<Object>
//                                 : const AssetImage(
//                                   'assets/images/default_profile.png',
//                                 ),
//                         backgroundColor: AppColor.myblue,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       _userProfile?.name ?? 'Nama Pengguna',
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     Text(
//                       _userProfile?.email ?? 'email@example.com',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                     Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildInfoRow(
//                               Icons.person,
//                               'Nama Lengkap',
//                               _userProfile?.name ?? '-',
//                             ),
//                             _buildInfoRow(
//                               Icons.email,
//                               'Email',
//                               _userProfile?.email ?? '-',
//                             ),
//                             _buildInfoRow(
//                               Icons.wc,
//                               'Jenis Kelamin',
//                               _formatGender(_userProfile?.jenisKelamin),
//                             ),
//                             _buildInfoRow(
//                               Icons.group,
//                               'Batch',
//                               _userProfile?.batchKe ?? '-',
//                             ),
//                             _buildInfoRow(
//                               Icons.school,
//                               'Training',
//                               _userProfile?.trainingTitle ?? '-',
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton.icon(
//                         onPressed: () async {
//                           final result = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const EditProfilePage(),
//                             ),
//                           );
//                           if (result == true) {
//                             _loadUserProfile();
//                           }
//                         },
//                         icon: const Icon(Icons.edit, color: Colors.white),
//                         label: const Text(
//                           "Ubah Profil",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColor.myblue,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           elevation: 4,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton.icon(
//                         onPressed:
//                             _showLogoutConfirmationDialog, // Panggil dialog konfirmasi
//                         icon: const Icon(Icons.logout, color: Colors.white),
//                         label: const Text(
//                           "Logout",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           elevation: 4,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, color: AppColor.myblue, size: 24),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
