// ignore_for_file: prefer_const_constructors, avoid_print, use_super_parameters, use_build_context_synchronously

import 'package:book_app/pages/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryPage extends StatefulWidget {
  final String kategori;
  const CategoryPage({Key? key, required this.kategori}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late List<Map<String, dynamic>> _books = [];
  late String _categoryName="";

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

Future<Map<String, dynamic>> getCategory(String categoryID) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore.instance.collection('Kategori').doc(categoryID).get();
    return docSnapshot.data() ?? {};
  } catch (error) {
    print('Error getting category: $error');
    return {};
  }
}



 Future<void> loadBooks() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Kitaplar')
        .where('kategoriID', isEqualTo: widget.kategori)
        .get();
    List<Map<String, dynamic>> booksData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    if (booksData.isNotEmpty) {
      String categoryID = booksData[0]['kategoriID'];
      Map<String, dynamic> categoryData = await getCategory(categoryID);
      String categoryName = categoryData['kategori_ad'];
      for (Map<String, dynamic> book in booksData) {
        String authorID = book['yazarID'];
        
        Map<String, dynamic> authorData = await getAuthor(authorID);
        String authorName = authorData['yazar_ad'] ?? 'Bilinmiyor';

        book['yazar_ad'] = authorName;
      }

      setState(() {
        _books = booksData;
        _categoryName = categoryName;
      });
    }
  } catch (error) {
    print('Error loading books: $error');
  }
}

Future<Map<String, dynamic>> getAuthor(String authorID) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore.instance.collection('Yazar').doc(authorID).get();
    return docSnapshot.data() ?? {};
  } catch (error) {
    print('Error getting author: $error');
    return {};
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_categoryName),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.all(10),
        child: Container(
          padding: EdgeInsets.all(10),
           decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,),
          child: ListView.builder(
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
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
                                                        Text(
                                                          _books[index]["yazar_ad"],
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
                    );
                  },
                ),
        ),
      )
          
    );
  }
}
