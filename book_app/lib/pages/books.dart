// ignore_for_file: use_key_in_widget_constructors, avoid_unnecessary_containers, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookPage extends StatefulWidget {
  const BookPage({Key? key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final CollectionReference kitap = FirebaseFirestore.instance.collection('Kitaplar');
  final CollectionReference yazar = FirebaseFirestore.instance.collection('Yazar');
  final CollectionReference kategori = FirebaseFirestore.instance.collection('Kategori');
  final CollectionReference yayinevi = FirebaseFirestore.instance.collection('Yayinevi');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
        ),
        body: StreamBuilder(
          stream: kitap.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List bookList = snapshot.data!.docs;
              return Container(
                child: Column(
                  children: [
                    Text('Kitaplar'),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: bookList.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document = bookList[index];
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          return FutureBuilder(
                            future: Future.wait([
                              yazar.doc(data['yazarID']).get(),
                              kategori.doc(data['kategoriID']).get(),
                              yayinevi.doc(data['yayineviID']).get(),
                            ]),
                            builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Text('Data not found');
                              }

                              Map<String, dynamic> authorData = snapshot.data![0].data() as Map<String, dynamic>;
                              String authorName = authorData['yazar_ad'] ?? 'Unknown';

                              Map<String, dynamic> categoryData = snapshot.data![1].data() as Map<String, dynamic>;
                              String categoryName = categoryData['kategori_ad'] ?? 'Unknown';

                              Map<String, dynamic> publisherData = snapshot.data![2].data() as Map<String, dynamic>;
                              String publisherName = publisherData['yayinevi_ad'] ?? 'Unknown';

                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  color: Colors.deepOrange.shade200,
                                  child: Column(
                                    children: [
                                      Text('Kitap Adı: ${data['kitap_ad']}'),
                                      Text('Yazar: $authorName'),
                                      Text('Kategori: $categoryName'),
                                      Text('Yayınevi : $publisherName'),
                                      Text('Basım Tarihi: ${data['btarihi']}'),
                                      Text('Dil: ${data['dil']}'),
                                      Text('Özet: ${data['ozet']}'),
                                      Text('Sayfa Sayısı: ${data['sayfa_sayisi']}'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Text('No book');
            }
          },
        ),
      ),
    );
  }
}
