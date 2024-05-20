// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
 

  final CollectionReference kullanicilar = FirebaseFirestore.instance.collection('users');
  final CollectionReference kitaplar = FirebaseFirestore.instance.collection('Kitap');
  final CollectionReference kategoriler = FirebaseFirestore.instance.collection('Kategori');

  Stream<QuerySnapshot> getUserStream(){
    final kullanicilarStream = kullanicilar.snapshots();
    return kullanicilarStream;
  }

 Stream<QuerySnapshot> getBookStream(){
  
    final kitaplarStream =kitaplar.snapshots();
    return kitaplarStream;
  }
Future<String> deneme(String id) async {
  String isim =  "";
  final value = await kategoriler.doc(id).get();
  isim = value['kategori_ad'] as String;
 return isim;
}













}

   
    
        
   


