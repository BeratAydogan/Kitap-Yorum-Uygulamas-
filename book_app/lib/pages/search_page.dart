// ignore_for_file: library_private_types_in_public_api, avoid_types_as_parameter_names, avoid_print, prefer_const_constructors, use_build_context_synchronously

import 'dart:async';

import 'package:book_app/pages/category_page.dart';
import 'package:book_app/pages/detail_page.dart';
import 'package:book_app/pages/search_page2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchText = '';
  String _sortBy = 'Puan'; 
  List<Map<String, dynamic>> _books = [];






Future<void> ekle()async {

  List<String> idler = [];
List<String> idler2 = [];
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("Kitaplar").get();
QuerySnapshot snapshot2 = await FirebaseFirestore.instance.collection("Kategori").get();
    for (var doc in snapshot.docs) {
      idler.add(doc.id);
    }
    for (var doc in snapshot2.docs) {
      idler2.add(doc.id);
    }
  for(String id in idler){
    FirebaseFirestore.instance.collection("Kitaplar").doc(id).update({'id':id});
  }

  for(String id in idler2){
    FirebaseFirestore.instance.collection("Kategori").doc(id).update({'id':id});
  }
    




  } catch (e) {
    print("Kitap ID'leri alınırken bir hata oluştu: $e");
    
  }
  
}











  @override
  void initState() {
    super.initState();
    loadBooks(); 
    ekle();
  }
Future<void> loadBooks() async {
  try {
    QuerySnapshot? querySnapshot;
    if (_sortBy == "Puan") {
      querySnapshot = await FirebaseFirestore.instance.collection('Kitaplar').orderBy("puan", descending: true).get();
    } else if (_sortBy == "Görüntü") {
      querySnapshot = await FirebaseFirestore.instance.collection('Kitaplar').get();

      List<Map<String, dynamic>> booksData = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      List<int> imageCounts = booksData.map((book) => int.parse(book['goruntu'])).toList();
      imageCounts.sort((a, b) => b.compareTo(a));

      List<String> sortedImageCounts = imageCounts.map((count) => count.toString()).toList();

      List<Map<String, dynamic>> sortedBooks = [];
      List<String> sortedImageCountsAdded = []; 
      for (String imageCount in sortedImageCounts) {
        for (Map<String, dynamic> book in booksData) {
          if (book['goruntu'] == imageCount && !sortedImageCountsAdded.contains(imageCount)) {
            sortedBooks.add(book);
            sortedImageCountsAdded.add(imageCount);
          }
        }
      }

      setState(() {
        _books = sortedBooks;
      });
      return;    
    } else if (_sortBy == "Sayfa") {
      querySnapshot = await FirebaseFirestore.instance.collection('Kitaplar').get();

      List<Map<String, dynamic>> booksData = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      List<int> pageNumbers = booksData.map((book) => int.parse(book['sayfa_sayisi'])).toList();
      pageNumbers.sort((a, b) => b.compareTo(a)); 

      List<String> sortedPageNumbers = pageNumbers.map((number) => number.toString()).toList();

      List<Map<String, dynamic>> sortedBooks = [];
      List<String> sortedPageNumbersAdded = []; 
      for (String pageNumber in sortedPageNumbers) {
        for (Map<String, dynamic> book in booksData) {
          if (book['sayfa_sayisi'] == pageNumber && !sortedPageNumbersAdded.contains(pageNumber)) {
            sortedBooks.add(book);
            sortedPageNumbersAdded.add(pageNumber);
          }
        }
      }

      setState(() {
        _books = sortedBooks;
      });
      return;
    } else if (_sortBy == "Kategori") {
      querySnapshot = await FirebaseFirestore.instance.collection('Kategori').orderBy('kategori_ad', descending: false).get();
    }

    if (querySnapshot == null) {
      return;
    }

    List<Map<String, dynamic>> booksData = querySnapshot.docs.map((doc) {
      Map<String, dynamic> bookData = doc.data() as Map<String, dynamic>;
      bookData['id'] = doc.id; 
      if (bookData['kategori_ad'] == null) {
        bookData['kategori_ad'] = "";
      }
      if (bookData['kitap_ad'] == null) {
        bookData['kitap_ad'] = ""; 
      }
      if (bookData['dil'] == null) {
        bookData['dil'] = ""; 
      }
      if (bookData['sayfa_sayisi'] == null) {
        bookData['sayfa_sayisi'] = ""; 
      }
      if (bookData['goruntu'] == null) {
        bookData['goruntu'] = ""; 
      }
      if (bookData['puan'] == null) {
        bookData['puan'] = ""; 
      }
      if (bookData['resim'] == null) {
        bookData['resim'] = "";
      }
      return bookData;
    }).toList();
   

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          foregroundColor: Colors.white,
          centerTitle: true,
          backgroundColor: Colors.black87,
          title: SizedBox(
            height: 40,
            width: 350,
            child: Padding(
              padding: EdgeInsets.only(top: 0, left: 5, right: 10),
              child: TextFormField(
                readOnly: true,
                onTap: () {
Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage2(),
      ),
    );                },
                obscureText: false,
                decoration: InputDecoration(
                  labelText: 'Arama Yap',
                  alignLabelWithHint: false,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.amber),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                  ),
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
         
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSortOption('Kategori', Icons.category),
                    Divider(),
                    _buildSortOption('Puan', Icons.star),
                    _buildSortOption('Görüntü', Icons.remove_red_eye),
                    _buildSortOption('Sayfa', Icons.insert_drive_file),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: ListView.builder(
                  itemCount: _books.length, 
                  itemBuilder: (context, index) {
                     
                    return  _sortBy=="Puan"? GestureDetector(
                     onTap: () async {
  try {
    
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore.instance.collection('Kitaplar').doc(_books[index]['id']).get();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(bookData: docSnapshot),
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
                              child: Text("${index+1}.",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
                            Container(
                                                  width: 60,
                                                  margin:
                                                      EdgeInsets.only(right: 15),
                                                  child: _books[index]['resim']!=null? Image(
                                                    image:
                                                        NetworkImage(_books[index]['resim']),
                                                    fit: BoxFit.contain,
                                                  ):CircularProgressIndicator(),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                     
                                                      Text(
                                                        _books[index]["kitap_ad"],
                                                        maxLines: 1,
                                                        overflow: TextOverflow.clip,
                                                      ),
                                                    
                                                      Row(
                                                        children: [
                                                          Text(
                                                            _books[index]["dil"] + " • ",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.black45),
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .insert_drive_file_outlined,
                                                            color: Colors.black45,
                                                            size: 15,
                                                          ),
                                                          Text(_books[index]["sayfa_sayisi"],
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black45))
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                      
                          Container(
                            padding: EdgeInsets.only(right: 10),
                            child: Row(
                              children: [
                                Text(_books[index]["puan"]),
                                Icon(Icons.star,color: Colors.amber.shade800,),
                              ],
                            ),
                          )
                          ],
                        ),
                      ),
                    ):_sortBy=="Kategori"?Container(
                      padding: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(_books[index]['kategori_ad'],style: TextStyle(fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,),
                        
                        onTap: () {
                         
                           Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(kategori: _books[index]["id"]),
      ),
    );
                        },
                      ),
                    ):_sortBy=="Görüntü"?GestureDetector(
                      onTap: () async {
                      
  try {
   
    
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore.instance.collection('Kitaplar').doc(_books[index]['id']).get();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(bookData: docSnapshot),
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
                              child: Text("${index+1}.",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
                            Container(
                                                  width: 60,
                                                  margin:
                                                      EdgeInsets.only(right: 15),
                                                  child: Image(
                                                    image:
                                                        NetworkImage(_books[index]['resim']),
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                     
                                                      Text(
                                                        _books[index]["kitap_ad"],
                                                        maxLines: 1,
                                                        overflow: TextOverflow.clip,
                                                      ),
                                                    
                                                      Row(
                                                        children: [
                                                          Text(
                                                            _books[index]["dil"] + " • ",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.black45),
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .insert_drive_file_outlined,
                                                            color: Colors.black45,
                                                            size: 15,
                                                          ),
                                                          Text(_books[index]["sayfa_sayisi"],
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black45))
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                      
                          Container(
                            padding: EdgeInsets.only(right: 10),
                            child: Row(
                              children: [
                                Text(_books[index]["goruntu"]),
                                Icon(Icons.remove_red_eye,color: Colors.amber.shade800,),
                              ],
                            ),
                          )
                          ],
                        ),
                      ),
                    ):GestureDetector(
                      onTap: () async {
  try {
    
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore.instance.collection('Kitaplar').doc(_books[index]['id']).get();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(bookData: docSnapshot),
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
                              child: Text("${index+1}.",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
                            Container(
                                                  width: 60,
                                                  margin:
                                                      EdgeInsets.only(right: 15),
                                                  child: Image(
                                                    image:
                                                        NetworkImage(_books[index]['resim']),
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                     
                                                      Text(
                                                        _books[index]["kitap_ad"],
                                                        maxLines: 1,
                                                        overflow: TextOverflow.clip,
                                                      ),
                                                    
                                                      Row(
                                                        children: [
                                                          Text(
                                                            _books[index]["dil"] + " • ",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.black45),
                                                          ),
                                                          Icon(
                                                            Icons.star,color: Colors.amber.shade800,
                                                            size: 15,
                                                          ),
                                                          Text(_books[index]["puan"],
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black45))
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                      
                          Container(
                            padding: EdgeInsets.only(right: 10),
                            child: Row(
                              children: [
                                Text(_books[index]["sayfa_sayisi"]),
                                Icon(Icons.insert_drive_file_outlined,color: Colors.amber.shade800,),
                              ],
                            ),
                          )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildSortOption(String option, IconData iconn) {
  return GestureDetector(
    onTap: () {
      setState(() {
        _sortBy = option;
        _searchText = option;
        print(_searchText);
        loadBooks(); 
      });
    },
    child: _sortBy == option
        ?  Column(
              children: [
                Icon(
                  iconn,
                
                          
                  color: _sortBy == option ? Colors.amber.shade800 : Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _sortBy == option
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _sortBy == option ? Colors.amber.shade800 : Colors.white,
                    ),
                  ),
                ),
              ],
            
          )
        : Column(
            children: [
              Icon(
                iconn,
                  color: _sortBy == option ? Colors.amber.shade800 : Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: _sortBy == option
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _sortBy == option ? Colors.amber.shade800 : Colors.white,
                  ),
                ),
              ),
            ],
          ),
  );
}

}
