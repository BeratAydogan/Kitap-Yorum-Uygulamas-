// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PublisherPage extends StatefulWidget {
  const PublisherPage({super.key});

  @override
  State<PublisherPage> createState() => _PublisherPageState();
}

class _PublisherPageState extends State<PublisherPage> {
  final CollectionReference yayinevi = FirebaseFirestore.instance.collection('Yayinevi');

  
 
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
        backgroundColor: Colors.deepOrange,
      ),
          body: StreamBuilder(
              stream: yayinevi.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List publisherList = snapshot.data!.docs;
                  return Container(
                    child: Column(
                      children: [
                        Text('Yayınevleri'),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                              itemCount: publisherList.length,
                              itemBuilder: (BuildContext context, int index) {
                                DocumentSnapshot document = publisherList[index];
                                  
                                Map<String, dynamic> data =
                                    document.data() as Map<String, dynamic>;
                                  
                                return 
                                   ListTile(
                                    title: Text(data['yayinevi_ad']+' '+data['mail'].toString() ),
                                    subtitle: Text(data['site']+' '+data['numara']),
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