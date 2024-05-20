// ignore_for_file: library_private_types_in_public_api, empty_catches, prefer_const_constructors, use_build_context_synchronously, avoid_print, file_names

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Deneme extends StatefulWidget {
  const Deneme({super.key});

  @override
  _DenemeState createState() => _DenemeState();
}

class _DenemeState extends State<Deneme> {
  late List<dynamic> items;
  final _kitapAd = TextEditingController();
  final CollectionReference kategori =
      FirebaseFirestore.instance.collection('Kategori');
  final CollectionReference yayinevi =
      FirebaseFirestore.instance.collection('Yayinevi');
  final CollectionReference yazar =
      FirebaseFirestore.instance.collection('Yazar');
final CollectionReference kitap =
      FirebaseFirestore.instance.collection('Kitaplar');


  @override
  void initState() {
    super.initState();
    fetchData();
    items = [];
  }

  Future<void> fetchData() async {
    final searchKeyword = _kitapAd.text;
    if (searchKeyword.isEmpty) {
      return; // Boş bir arama yapmaktan kaçının
    }
    final response = await http.get(Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=$searchKeyword&printType=books&key=AIzaSyDz68YEC0ib36x3d1i09TH7Eja2vk0eYmo'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final items = jsonData['items'];
      setState(() {
        this.items = items;
      });
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API ile Kitap Ekle'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _kitapAd,
            onSubmitted: (value) {
              fetchData();
            },
            decoration: InputDecoration(
              hintText: 'Kitap Adı ile Ara',
              border: InputBorder.none,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final List<dynamic>? categories =
                    item['volumeInfo']['categories'];
                final String title =
                    item['volumeInfo']['title'] ?? 'Unknown Title';
                final String author =
                    item['volumeInfo']['authors'][0] ?? 'Unknown Author';
                final String publisher =
                    item['volumeInfo']['publisher'] ?? 'Unknown publisher';
                    final String publishDate =
                    item['volumeInfo']['publishedDate'] ?? 'Unknown published Date';
                final String ozet =
                    item['volumeInfo']['description'] ?? 'Unknown desc';
                final String pageCount =
                    item['volumeInfo']['pageCount'].toString();
                String language =
                    item['volumeInfo']['language'] ?? 'Unknown language';
                final String category =
                    categories != null && categories.isNotEmpty
                        ? categories[0].toString()
                        : 'Unknown Category';
                final String thumbnailUrl =
                    item['volumeInfo']['imageLinks']['thumbnail'] ?? '';
                if (language == "tr") {
                  language = "Türkçe";
                }
                if (language == "en") {
                  language = "İngilizce";
                }
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        thumbnailUrl.isNotEmpty
                            ? Image.network(thumbnailUrl)
                            : SizedBox.shrink(),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () async {
                           String yeniYazar="";
                           String yeniYayin="";
                           String yeniKategori="";
                            final kategoriTest = await kategori
                                .where('kategori_ad', isEqualTo: category)
                                .get();
                            final yayineviTest = await yayinevi
                                .where('yayinevi_ad', isEqualTo: publisher)
                                .get();
                            final yazarTest = await yazar
                                .where('yazar_ad', isEqualTo: author)
                                .get();
                            final kitapTest = await kitap.where('kitap_ad',isEqualTo: title).get();
                           
                            if (yazarTest.docs.isEmpty) {
                             final yazarRef= await yazar.add({
                                'yazar_ad': author,
                                'hakkinda': author,
                                'resim': author,
                              });
                           yeniYazar=yazarRef.id;
                            
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Yazar eklendi: $author')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Yazar zaten mevcut: $author')),
                
                              );
                          yeniYazar=yazarTest.docs.first.id;
                                
                              
                            }
                print(yeniYazar);
                            if (yayineviTest.docs.isEmpty) {
                               final yayineviRef=await yayinevi.add({
                                'yayinevi_ad': publisher,
                                'site': publisher,
                                'numara': publisher,
                                'mail': publisher,
                                'adres': publisher,
                                'resim': publisher,
                              });
                               yeniYayin= yayineviRef.id;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Yayinevi eklendi: $publisher')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Yayinevi zaten mevcut: $publisher')),
                              );
                               yeniYayin=yayineviTest.docs.first.id;
                            }
                            if (kategoriTest.docs.isEmpty) {
                             final kategoriRef=await kategori.add({
                                'hakkinda': category,
                                'kategori_ad': category,
                              });
                               yeniKategori = kategoriRef.id;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Kategori eklendi: $category')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Kategori zaten mevcut: $category')),
                              );
                               yeniKategori=kategoriTest.docs.first.id;
                            }
                              if(kitapTest.docs.isEmpty){
                         kitap.add({
                      'kitap_ad': title,
                      'sayfa_sayisi':pageCount,
                      'dil': language,
                      'ozet': ozet,
                      'btarihi': publishDate,
                      'kategoriID': yeniKategori,
                      'yazarID': yeniYazar,
                      'yayineviID': yeniYayin,
                      'resim': thumbnailUrl,
                      'puan':"0",
                      'goruntu':"0",
                    });
                     ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Kitap eklendi: $title')),
                  );
                      }else{
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Kitap zaten mevcut: $title')),
                  );
                      }
                          },
                        )
                      ],
                    ),
                    Text(title),
                    Text('Author: $author\nCategory: $category'),
                    Text(publisher),
                    Text(pageCount),
                    Text(language),
                    Text(publishDate),
                    Text(ozet),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
