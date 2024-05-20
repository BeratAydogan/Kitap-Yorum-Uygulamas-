// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
 
  final _kategoriAd = TextEditingController();
  final _hakkinda = TextEditingController();
  final CollectionReference kategori = FirebaseFirestore.instance.collection('Kategori');

   kategoriEkle(){
  
    kategori.add({
      'hakkinda':_hakkinda.text.trim(),
      'kategori_ad':_kategoriAd.text.trim(),
  });
  }


 

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                            controller: _kategoriAd,
                            decoration: InputDecoration(
                              hintText: 'Kategori Adı',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                            controller: _hakkinda,
                            decoration: InputDecoration(
                              hintText: 'Hakkında',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
              
                SizedBox(height: 20,),
                
                
                ElevatedButton(onPressed: kategoriEkle, child: Text('Kaydet')),
               
                
              ],
            ),
          ),
        ),
      ),
    );
  }
  }