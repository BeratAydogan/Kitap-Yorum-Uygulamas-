// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_import, avoid_unnecessary_containers

import 'package:book_app/read%20data/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthorsPage extends StatefulWidget {
  const AuthorsPage({super.key});

  @override
  State<AuthorsPage> createState() => _AuthorsPageState();
}

class _AuthorsPageState extends State<AuthorsPage> {

    final CollectionReference yazar = FirebaseFirestore.instance.collection('Yazar');

  
 
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
        backgroundColor: Colors.deepOrange,
      ),
          body: StreamBuilder(
              stream: yazar.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List authorList = snapshot.data!.docs;
                  return Container(
                    child: Column(
                      children: [
                        Text('Yazarlar'),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                              itemCount: authorList.length,
                              itemBuilder: (BuildContext context, int index) {
                                DocumentSnapshot document = authorList[index];
                                  
                                Map<String, dynamic> data =
                                    document.data() as Map<String, dynamic>;
                                  
                                return 
                                   ListTile(
                                    title: Text(data['yazar_ad']),
                                    subtitle: Text(data['hakkinda']),
                                    leading: Image(image: NetworkImage(data['resim']),fit: BoxFit.contain,),
                                  );
                                
                              }),
                        ),
                      ],
                    ),
                  );
                }else {
                  return Text('No book');
                }
              }
              ),
        ),
    );
    
  }
}
