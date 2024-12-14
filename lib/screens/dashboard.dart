// ignore_for_file: deprecated_member_use

import 'package:buang_bijak/screens/user_settings.dart';
import "package:flutter/material.dart";
import '../screens/dashboard_detail.dart';
import '../models/dashboard.dart';
import '../widgets/dashboard_card.dart';
import 'package:flutter/services.dart'; // Untuk SystemNavigator.pop()

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  Future<bool> _onWillPop() async {
    SystemNavigator.pop(); // Keluar dari aplikasi
    return Future.value(true); // Mengizinkan aksi back
  }

  @override
  Widget build(BuildContext context) {
    final List<DashboardData> dashboardData = [
      DashboardData(
        date: 'Hari ini - Pukul 10.00 WIB',
        wasteType: '12 Juni 2024 - Sampah Kertas, Botol, dan Plastik',
        address:
            'Jl. Sutorejo Tengah No.10, Dukuh Sutorejo, Kec. Mulyorejo, Surabaya, Jawa Timur 60113',
        status: 'Ditugaskan',
      ),
      DashboardData(
        date: 'Hari ini - Pukul 10.00 WIB',
        wasteType: '16 Juni 2024 - Sampah Kertas, Botol, dan Plastik',
        address:
            'Jl. Sutorejo Tengah No.10, Dukuh Sutorejo, Kec. Mulyorejo, Surabaya, Jawa Timur 60113',
        status: 'Selesai',
      ),
      DashboardData(
        date: 'Hari ini - Pukul 10.00 WIB',
        wasteType: '8 Juni 2024 - Sampah Kertas, Botol, dan Plastik',
        address:
            'Jl. Sutorejo Tengah No.10, Dukuh Sutorejo, Kec. Mulyorejo, Surabaya, Jawa Timur 60113',
        status: 'Dibatalkan',
      ),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Dashboard'),
          automaticallyImplyLeading: false, // Menghilangkan tombol back
        ),
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: dashboardData
                    .map((data) => Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: DashboardCard(
                            iconPath: 'assets/icons/calendar.png',
                            date: data.date,
                            details: data.wasteType,
                            address: data.address,
                            status: data.status,
                            buttonText: 'Lihat Detail',
                            buttonAction: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DashboardDetail(),
                                ),
                              );
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserSettings()),
              );
            }
          },
        ),
      ),
    );
  }
}
