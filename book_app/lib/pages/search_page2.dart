// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_app/pages/detail_page.dart';

class SearchPage2 extends StatefulWidget {
  const SearchPage2({super.key});

  @override
  State<SearchPage2> createState() => _SearchPage2State();
}

class _SearchPage2State extends State<SearchPage2> {
  String _searchText = '';
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Kitaplar').get();
      List<Map<String, dynamic>> booksData = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        _books = booksData;
      });
    } catch (error) {
      print('Error loading books: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: TextField(
          onChanged: (text) {
            setState(() {
              _searchText = text;
              _filteredBooks = _books
                  .where((book) =>
                      book['kitap_ad']
                          .toLowerCase()
                          .contains(_searchText.toLowerCase()))
                  .toList();
            });
          },
          decoration: InputDecoration(
            hintText: 'Arama Yap...',
          ),
        ),
        actions: [
          
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5), 
        spreadRadius: 5, 
        blurRadius: 7, 
        offset: Offset(0, 3), 
      ),
    ],
        ),
             
  
    

        child: Column(
          children: [
            Row(
     mainAxisAlignment: MainAxisAlignment.end,

              children: [
                ElevatedButton(
                  onPressed: () {  },
                  child: PopupMenuButton<String>(
                    
                    icon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("Filtre",style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        Icon(Icons.filter_alt_rounded,color: Colors.amber.shade800,)
                      ],
                    ),
                  onSelected: (value) {
                    setState(() {
                      _filteredBooks = _filteredBooks.isNotEmpty
                          ? _filteredBooks
                          : _books;  
                      _filteredBooks.sort((a, b) => compareValues(a, b, value));
                    });
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'puan',
                      child: Text('Puana Göre'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'goruntu',
                      child: Text('Görüntülenme Sayısına Göre'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'sayfa_sayisi',
                      child: Text('Sayfa Sayısına Göre'),
                    ),
                  
                  ],
                            ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredBooks.isEmpty ? 1 : _filteredBooks.length,
                itemBuilder: (context, index) {
                  return _filteredBooks.isNotEmpty
                      ? GestureDetector(
                          onTap: () async {
                            try {
                              DocumentSnapshot<Map<String, dynamic>>
                                  docSnapshot = await FirebaseFirestore.instance
                                      .collection('Kitaplar')
                                      .doc(_filteredBooks[index]['id'])
                                      .get();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailPage(bookData: docSnapshot),
                                ),
                              );
                            } catch (error) {
                              print('Error navigating to detail page: $error');
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 20),
                            height: 100,
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  margin: EdgeInsets.only(right: 10),
                                  child: Text(
                                    "${index + 1}.",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 60,
                                  margin: EdgeInsets.only(right: 15),
                                  child: _books[index]['resim'] != null
                                      ? Image(
                                          image: NetworkImage(
                                              _filteredBooks[index]['resim']),
                                          fit: BoxFit.contain,
                                        )
                                      : CircularProgressIndicator(),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _filteredBooks[index]["kitap_ad"],
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                      ),
                                     
                                      Row(
                                        children: [
                                          Text(
                                            _filteredBooks[index]["dil"] + " • ",
                                            style: TextStyle(
                                              color: Colors.black45,
                                            ),
                                          ),
                                          Icon(
                                            Icons.insert_drive_file_rounded,
                                            color: Colors.amber.shade800,
                                            size: 15,
                                          ),
                                          Text(
                                            _filteredBooks[index]["sayfa_sayisi"],
                                            style: TextStyle(
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                         
                                          Icon(
                                            Icons.remove_red_eye,
                                            color: Colors.amber.shade800,
                                            size: 15,
                                          ),
                                          Text(
                                            _filteredBooks[index]["goruntu"],
                                            style: TextStyle(
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Row(
                                    children: [
                                      Text(_filteredBooks[index]["puan"]),
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber.shade800,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Center(child: Text("Aranan Kitap Bulunamadı")));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int compareValues(
      Map<String, dynamic> a, Map<String, dynamic> b, String sortBy) {
    switch (sortBy) {
      case 'puan':
        return double.parse(b[sortBy]).compareTo(double.parse(a[sortBy]));
      case 'goruntu':
        return int.parse(b[sortBy]).compareTo(int.parse(a[sortBy]));
      case 'sayfa_sayisi':
        return int.parse(b[sortBy]).compareTo(int.parse(a[sortBy]));
      default:
        return 0;
    }
  }
}
