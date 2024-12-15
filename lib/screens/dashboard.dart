// ignore_for_file: use_build_context_synchronously

import "package:flutter/material.dart";
import '../screens/dashboard_detail.dart';
import '../widgets/dashboard_card.dart';
import '../theme.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buang_bijak/utils/date_helper.dart';

final Logger logger = Logger();

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  Future<String> fetchUserFullName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return (userDoc.data() as Map<String, dynamic>)['fullName'] ?? '';
      }
      return 'User not found';
    } catch (e) {
      logger.e('Error fetching user data', error: e);
      return 'Error fetching user';
    }
  }

  Future<List<Map<String, dynamic>>> fetchPickupData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ajukan_pickup')
          .orderBy('tanggal_pickup')
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      logger.e('Error fetching pickups', error: e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: white,
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    surfaceTintColor: Colors.transparent,
                    pinned: true,
                    title: Text(
                      'Jadwal Pickup',
                      style: bold20.copyWith(color: black),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Banner Image
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.asset(
                          'assets/images/truck-banner.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),

                  // Pickup Data List
                  SliverToBoxAdapter(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchPickupData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Terjadi kesalahan: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('Tidak ada data pickup.'));
                        }

                        List<Map<String, dynamic>> dashboardData =
                            snapshot.data ?? [];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: dashboardData.map((data) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: DashboardCard(
                                  iconPath: 'assets/icons/calendar.png',
                                  date: formatPickupDate(
                                      data['tanggal_pickup'].toDate()),
                                  details: data['jenis_sampah'],
                                  address: data['lokasi_pickup'],
                                  status: data['status'],
                                  buttonText: 'Lihat Detail',
                                  buttonAction: () async {
                                    String fullName = await fetchUserFullName(
                                        data['user_id']);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DashboardDetail(
                                          status: data['status'],
                                          wasteType: data['jenis_sampah'],
                                          address: data['lokasi_pickup'],
                                          date: formatPickupDate(
                                              data['tanggal_pickup'].toDate()),
                                          time: data['waktu_pickup'],
                                          orderId: data['order_id'],
                                          rejectedReason:
                                              data['rejectedReason'],
                                          fullName:
                                              fullName, // Data fullName dari koleksi users
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),

              // Floating Navigation Bar
              Positioned(
                bottom: 4,
                left: 16,
                right: 16,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    selectedItemColor: Colors.black,
                    unselectedItemColor: Colors.black38,
                    selectedLabelStyle: regular12,
                    unselectedLabelStyle: regular12,
                    items: [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home_rounded), label: 'Beranda'),
                      // BottomNavigationBarItem(
                      //     icon: Icon(Icons.inbox), label: 'Pickup'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.person), label: 'Profile'),
                    ],
                    onTap: (index) {
                      String routeName;
                      switch (index) {
                        case 0:
                          routeName = '/';
                          break;
                        // case 1:
                        //   routeName = '/ajukan-pickup';
                        //   break;
                        case 1:
                          routeName = '/profil-saya';
                          break;
                        default:
                          routeName = '/';
                      }
                      Navigator.pushReplacementNamed(context, routeName);
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
