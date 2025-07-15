import 'dart:convert';

import 'package:aplikasi_absensi/api/endpoint.dart';
import 'package:aplikasi_absensi/constant/app_color.dart'; // Pastikan ini diimpor
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordPage extends StatefulWidget {
  static const String id = "/reset_password";
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _isPasswordVisible = false; // Untuk toggle visibilitas password baru
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan SnackBar
  void _showMessage(String message, {Color color = Colors.black}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _resetPassword(String email) async {
    if (!_formKey.currentState!.validate()) {
      return; // Hentikan jika validasi gagal
    }

    final otp = _otpController.text.trim();
    final newPassword = _passwordController.text.trim();

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse(Endpoint.resetPassword),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"email": email, "otp": otp, "password": newPassword}),
      );

      final json = jsonDecode(response.body);
      setState(() => _loading = false);

      if (response.statusCode == 200) {
        _showMessage(
          json['message'] ?? 'Password berhasil direset',
          color: Colors.green,
        );
        // Kembali ke halaman root (biasanya halaman login)
        Navigator.popUntil(context, ModalRoute.withName("/"));
      } else {
        _showMessage(
          json['message'] ?? 'Gagal reset password',
          color: Colors.red,
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      _showMessage('Terjadi kesalahan koneksi: $e', color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan email ada sebelum digunakan
    final String email =
        ModalRoute.of(context)?.settings.arguments as String? ??
        'email tidak ditemukan';

    return Scaffold(
      backgroundColor: AppColor.neutral, // Konsisten dengan halaman lain
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColor.myblue,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Atur Ulang Kata Sandi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.myblue,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Kami telah mengirimkan kode verifikasi ke email Anda. Silakan masukkan kode dan kata sandi baru Anda.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 40),

                // Input OTP
                _buildTitle("Kode Verifikasi (OTP)"),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number, // OTP biasanya angka
                  decoration: _buildInputDecoration(
                    hintText: "Masukkan kode OTP",
                    prefixIcon: Icons.vpn_key_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode OTP tidak boleh kosong';
                    }
                    if (value.length < 4) {
                      // Asumsi OTP 4 digit atau lebih
                      return 'Kode OTP minimal 4 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Input Password Baru
                _buildTitle("Kata Sandi Baru"),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: _buildInputDecoration(
                    hintText: "Masukkan kata sandi baru",
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColor.gray88,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Kata sandi minimal 6 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Tombol Reset Password
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : () => _resetPassword(email),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.myblue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child:
                        _loading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              "Reset Kata Sandi",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper untuk dekorasi input field
  InputDecoration _buildInputDecoration({
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon:
          prefixIcon != null ? Icon(prefixIcon, color: AppColor.gray88) : null,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColor.myblue, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // Widget untuk membangun judul section (misal: "Kode Verifikasi (OTP)")
  Widget _buildTitle(String text) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.myblue,
          ),
        ),
      ],
    );
  }
}

// import 'dart:convert';

// import 'package:aplikasi_absensi/api/endpoint.dart';
// import 'package:aplikasi_absensi/constant/app_color.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class ResetPasswordPage extends StatefulWidget {
//   static const String id = "/reset_password";
//   const ResetPasswordPage({super.key});

//   @override
//   State<ResetPasswordPage> createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final TextEditingController _otpController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _loading = false;
//   final bool _isPasswordVisible = false;
//   final _formKey = GlobalKey<FormState>();

//   Future<void> _resetPassword(String email) async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//     final otp = _otpController.text.trim();
//     final newPassword = _passwordController.text.trim();

//     if (otp.isEmpty || newPassword.isEmpty) return;

//     setState(() => _loading = true);

//     final response = await http.post(
//       Uri.parse(Endpoint.resetPassword),
//       headers: {
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({"email": email, "otp": otp, "password": newPassword}),
//     );

//     final json = jsonDecode(response.body);
//     setState(() => _loading = false);

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(json['message'])));
//       Navigator.popUntil(context, ModalRoute.withName("/"));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(json['message'] ?? 'Gagal reset password')),
//       );
//     }

//     void dispose() {
//       _otpController.dispose();
//       _passwordController.dispose();
//       super.dispose();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String email = ModalRoute.of(context)?.settings.arguments as String;

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text(
//           'Reset Password',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: AppColor.myblue,
//         foregroundColor: Colors.white,
//         elevation: 0.5,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text("OTP dikirim ke: $email"),
//             TextField(
//               controller: _otpController,
//               decoration: const InputDecoration(labelText: "OTP"),
//             ),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: "Password Baru"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loading ? null : () => _resetPassword(email),
//               child:
//                   _loading
//                       ? const CircularProgressIndicator()
//                       : const Text("Reset Password"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
