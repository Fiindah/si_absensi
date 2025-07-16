import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/view/dashboard_page.dart';
import 'package:aplikasi_absensi/view/history_page.dart';
import 'package:aplikasi_absensi/view/profile_page/profile_page.dart';
import 'package:flutter/material.dart';

class ButtonNavbarPage extends StatefulWidget {
  const ButtonNavbarPage({super.key});
  static const String id = "/butttom_navbar_page";

  @override
  State<ButtonNavbarPage> createState() => _ButtonNavbarPageState();
}

class _ButtonNavbarPageState extends State<ButtonNavbarPage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = [DashboardPage(), HistoryPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Riwayat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColor.myblue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }
}
