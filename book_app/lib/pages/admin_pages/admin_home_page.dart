// ignore_for_file: prefer_const_constructors

import 'package:book_app/pages/admin_pages/add_author.dart';
import 'package:book_app/pages/admin_pages/add_book.dart';
import 'package:book_app/pages/admin_pages/add_category.dart';
import 'package:book_app/pages/admin_pages/add_publisher.dart';
import 'package:book_app/pages/authors.dart';
import 'package:book_app/pages/books.dart';
import 'package:book_app/pages/publishers.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
      ),
      body:  SingleChildScrollView(
            child: Center(
              
              child: Column(
                children: [
                  SizedBox(height: 200,),
                  Row(children: [
                     ElevatedButton(
                    onPressed: (){
                    Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>AuthorsPage())
                    );
                  }, child: Text('Yazarları görüntüle')),
                     ElevatedButton(
                    onPressed: (){
                    Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>AddAuthorPage())
                    );
                  }, child: Text('Yazar Ekle')),
                  ],
                  ),
                    SizedBox(height: 50,),
                 Row(children: [
                  ElevatedButton(onPressed: (){
                      
                  }, child: Text('Kategorileri Görüntüle')),
              
                  ElevatedButton(onPressed: (){
                       Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>AddCategoryPage())
                    );
                  }, child: Text('Kategori Ekle')),
                 ],),
                  SizedBox(height: 50,),
                 
              
              
                Row(children: [
                     ElevatedButton(onPressed: (){
                    Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>PublisherPage())
                    );
                  }, child: Text('Yayınevlerini Görüntüle ')),
                   ElevatedButton(onPressed: (){
                    Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>AddPublisherPage())
                    );
                  }, child: Text('Yayınevi Ekle')),
                ],),
               
                  SizedBox(height: 50,),
                  Row(children: [
                      ElevatedButton(onPressed: (){
                    Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>BookPage())
                    );
                  }, child: Text('Kitapları Görüntüle')),
                      ElevatedButton(onPressed: (){
                    Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>AddBookPage())
                    );
                  }, child: Text('Kitap Ekle'))
                  ],),
                
              
                ],),
            ),
          ),
        
       
    );
  }
}