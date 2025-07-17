import 'package:aplikasi_absensi/view/auth_page/forgot_password.dart';
import 'package:aplikasi_absensi/view/auth_page/login_page.dart';
import 'package:aplikasi_absensi/view/auth_page/register_page.dart';
import 'package:aplikasi_absensi/view/auth_page/reset_password.dart';
import 'package:aplikasi_absensi/view/buttom_navbar_page.dart';
import 'package:aplikasi_absensi/view/check_in_page.dart';
import 'package:aplikasi_absensi/view/check_out_page.dart';
import 'package:aplikasi_absensi/view/dashboard_page.dart';
import 'package:aplikasi_absensi/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('id_ID', null).then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => const SplashScreen(),
        LoginPage.id: (context) => const LoginPage(),
        RegisterPage.id: (context) => const RegisterPage(),
        ForgotPasswordPage.id: (context) => const ForgotPasswordPage(),
        ResetPasswordPage.id: (context) => const ResetPasswordPage(),
        ButtonNavbarPage.id: (context) => const ButtonNavbarPage(),
        DashboardPage.id: (context) => DashboardPage(),
        CheckInPage.id: (context) => CheckInPage(),
        CheckOutPage.id: (context) => CheckOutPage(),
      },
      title: 'Aplikasi Absensi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
