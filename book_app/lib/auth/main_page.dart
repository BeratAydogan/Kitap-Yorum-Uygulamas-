// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:book_app/pages/category_select.dart';
import 'package:book_app/pages/home_page.dart';
import 'package:book_app/pages/list_page.dart';
import 'package:book_app/pages/login_page.dart';
import 'package:book_app/pages/profil_page.dart';
import 'package:book_app/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key,});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1;
final CollectionReference kullanici =
      FirebaseFirestore.instance.collection('users');
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    ListPage(), // şuanlık böyle sonra sayfalar gelecek
    HomePage(),
    SearchPage(),
    ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Oturum durumu kontrol edilirken, bir yükleme gösterebilirsiniz
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasData) {
              // Kullanıcı oturum açtıysa, ilgili sayfayı göster
              return StreamBuilder<DocumentSnapshot>(
                stream: kullanici
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasData) {
                      Map<String, dynamic> userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      if (userData["kategori"] == "" ||
                          userData["kategori"] == null) {
                        // Kullanıcının kategori alanı boşsa, kategori seçim sayfasına yönlendir
                        return CategorySelectPage();
                      } else {
                        // Kullanıcının kategori alanı doluysa, ana sayfayı göster
                        return Scaffold(
                          body: _pages[_selectedIndex],
                          bottomNavigationBar: Container(
                            color: Colors.black,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              child: GNav(
                                onTabChange: _onItemTapped,
                                selectedIndex: _selectedIndex,
                                gap: 8,
                                backgroundColor: Colors.black,
                                color: Colors.white,
                                activeColor: Colors.white,
                                tabBackgroundColor: Colors.grey.shade800,
                                padding: EdgeInsets.all(16),
                                tabs: const [
                                  GButton(
                                    icon: Icons.favorite_border,
                                    text: "Favoriler",
                                  ),
                                  GButton(icon: Icons.home, text: "Ana Sayfa"),
                                  GButton(icon: Icons.search, text: "Arama"),
                                  GButton(icon: Icons.person, text: "Profil"),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    } else {
                      return Center(
                        child: Text("Veri bulunamadı"),
                      );
                    }
                  }
                },
              );
            } else {
              // Kullanıcı oturum açmadıysa, LoginPage'i göster
              return LoginPage();
            }
          }
        },
      ),
    );
  }
}
