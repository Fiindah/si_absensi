import 'dart:convert';

import 'package:aplikasi_absensi/api/endpoint.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/view/auth_page/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  static const String id = "/forgot_password";
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _loading = true);

    final response = await http.post(
      Uri.parse(Endpoint.forgotPassword),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"email": email}),
    );

    final json = jsonDecode(response.body);
    setState(() => _loading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(json['message'])));
      Navigator.pushNamed(context, ResetPasswordPage.id, arguments: email);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(json['message'] ?? 'Terjadi kesalahan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutral,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Lupa Password',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.myblue,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0), // Padding yang lebih besar
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Agar elemen mengisi lebar
          children: [
            const SizedBox(height: 20),
            const Text(
              "Lupa Kata Sandi",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColor.myblue,
              ),
            ),
            const SizedBox(height: 40), // Spasi lebih banyak
            // Label untuk input email
            _buildTitle("Email"),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "contoh@gmail.com",
                // Ikon email
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ), // Padding konten
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Border radius
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ), // Warna border lebih soft
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
                fillColor: Colors.white, // Latar belakang field putih
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Masukkan email yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 30), // Spasi sebelum tombol
            // Tombol Kirim Kode Verifikasi
            SizedBox(
              width: double.infinity,
              height: 56, // Tinggi tombol konsisten dengan halaman login
              child: ElevatedButton(
                onPressed: _loading ? null : _submitEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.myblue, // Warna tombol
                  foregroundColor: Colors.white, // Warna teks tombol
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ), // Padding vertikal
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      30,
                    ), // Border radius tombol lebih membulat
                  ),
                  elevation: 4, // Shadow untuk tombol
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
                          "Kirim Kode Verifikasi",
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
      // body: Padding(
      //   padding: const EdgeInsets.all(24.0), // Padding yang lebih besar
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       const Text(
      //         "Masukkan alamat email Anda yang terdaftar untuk menerima kode verifikasi guna mereset password Anda.",
      //         textAlign: TextAlign.center,
      //         style: TextStyle(fontSize: 16, color: Colors.black87),
      //       ),
      //       const SizedBox(height: 30), // Spasi lebih banyak
      //       TextFormField(
      //         controller: _emailController,
      //         keyboardType: TextInputType.emailAddress,
      //         decoration: InputDecoration(
      //           labelText: "Email",
      //           hintText: "contoh@email.com",
      //           border: OutlineInputBorder(
      //             borderRadius: BorderRadius.circular(10), // Border radius
      //           ),
      //           prefixIcon: const Icon(Icons.email_outlined), // Icon email
      //           contentPadding: const EdgeInsets.symmetric(
      //             vertical: 16,
      //             horizontal: 12,
      //           ), // Padding konten
      //         ),
      //       ),
      //       const SizedBox(height: 20),
      //       ElevatedButton(
      //         onPressed: _loading ? null : _submitEmail,
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: AppColor.myblue, // Warna tombol
      //           foregroundColor: Colors.white, // Warna teks tombol
      //           padding: const EdgeInsets.symmetric(
      //             vertical: 14,
      //           ), // Padding vertikal
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(
      //               10,
      //             ), // Border radius tombol
      //           ),
      //           elevation: 3, // Shadow untuk tombol
      //         ),
      //         child:
      //             _loading
      //                 ? const SizedBox(
      //                   width: 24,
      //                   height: 24,
      //                   child: CircularProgressIndicator(
      //                     valueColor: AlwaysStoppedAnimation<Color>(
      //                       Colors.white,
      //                     ),
      //                     strokeWidth: 2,
      //                   ),
      //                 )
      //                 : const Text(
      //                   "Kirim Kode Verifikasi",
      //                   style: TextStyle(
      //                     fontSize: 16,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //       ),
      //     ],
      //   ),
      // ),

      // body: Padding(
      //   padding: const EdgeInsets.all(16.0),
      //   child: Column(
      //     children: [
      //       const Text("Masukkan email untuk reset password"),
      //       TextField(
      //         controller: _emailController,
      //         decoration: const InputDecoration(labelText: "Email"),
      //       ),
      //       const SizedBox(height: 20),
      //       ElevatedButton(
      //         onPressed: _loading ? null : _submitEmail,
      //         child:
      //             _loading
      //                 ? const CircularProgressIndicator()
      //                 : const Text("Kirim OTP"),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  // Widget untuk membangun judul section (Email)
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
