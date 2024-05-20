// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, avoid_print, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:book_app/pages/detail_page.dart';
import 'package:book_app/pages/liked_reviews.dart';
import 'package:book_app/pages/maked_reviews_page.dart';
import 'package:book_app/pages/profile_edit_page.dart';
import 'package:book_app/pages/show_review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference liste =
      FirebaseFirestore.instance.collection('Liste');
  final CollectionReference yorum =
      FirebaseFirestore.instance.collection('Yorum');
  final CollectionReference begeni =
      FirebaseFirestore.instance.collection('Begeni');
  final CollectionReference kitaplar =
      FirebaseFirestore.instance.collection('Kitaplar');
  late User? currentUser;
  late String? userName="?";
  late String? userSurName="";
  late String? userEmail="";
  late String? currentUserPhoto="";
late String reviewCountText = '0';
  List<DocumentSnapshot> selectedBooks = [];


late String totalInteractionCountText = '0';

Future<void> _getUserTotalInteractionCountAndSetState() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  int userTotalInteractionCount = await getTotalInteractionCount(userId);
  setState(() {
    totalInteractionCountText = userTotalInteractionCount.toString();
  });
}


Future<int> getTotalInteractionCount(String userId) async {
  try {
    QuerySnapshot<Map<String, dynamic>> likeQuerySnapshot = await FirebaseFirestore.instance
        .collection('Begeni')
        .where('uye_id', isEqualTo: userId).where("begeni",isEqualTo: "1")
        .get();
    QuerySnapshot<Map<String, dynamic>> dislikeQuerySnapshot = await FirebaseFirestore.instance
        .collection('Begeni')
        .where('uye_id', isEqualTo: userId).where("begeni",isEqualTo: "0")
        .get();
    return likeQuerySnapshot.size + dislikeQuerySnapshot.size;
  } catch (e) {
    print('Toplam etkileşim sayısı alınırken hata oluştu: $e');
    return -1;
  }
}



Future<int> getUserReviewCount(String userId) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('Yorum')
        .where('uye_id', isEqualTo: userId)
        .get();
    return querySnapshot.size;
  } catch (e) {
    print('Yorum sayısı alınırken hata oluştu: $e');
    return -1;
  }
}






  @override
  void initState() {
    super.initState();
    getUserData();
    _getUserReviewCountAndSetState();
    _getUserTotalInteractionCountAndSetState();
  }

  Future<void> getUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;
    final userData =
        await users.doc(currentUser!.uid).get();
    setState(() {
      userName = userData.get('isim');
      userSurName = userData.get('soyisim');
      userEmail = userData.get('eposta');
      currentUserPhoto = userData.get('profil_foto');
    });
  }
Future<void> _getUserReviewCountAndSetState() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    int userReviewCount = await getUserReviewCount(userId);
    setState(() {
      reviewCountText = userReviewCount.toString();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Profilim"),
        actions: [
          GestureDetector(
            onTap: (){

Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileEditPage(),
          ),
        );
            },
            child: Container(margin:EdgeInsets.only(right: 20,top: 10) ,
                          alignment: Alignment.topRight,
                          
                           
                            child: Icon(Icons.edit)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            color: Colors.white,
                                          ),
                margin: EdgeInsets.all( 15),
                padding: EdgeInsets.all(15),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(reviewCountText,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                              Text("İnceleme",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18))
                            ],
                          ),
                         CircleAvatar(
  radius: 50,
  child: currentUserPhoto!.isNotEmpty 
      ? ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.network(currentUserPhoto!, fit: BoxFit.cover),
        )
      : Container(
          decoration: BoxDecoration(
            color: Colors.amber.shade800,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              userName![0].toUpperCase(),
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
          ),
        ),
),
                          Column(
                            children: [
                              Text(totalInteractionCountText,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                              Text("Etkileşim",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18))
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        "$userName $userSurName",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        userEmail ?? 'Yükleniyor...',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
        
              Container(
                margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.only(
                            left: 10, right: 15, bottom: 30, top: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          color: Colors.black,
                        ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: (){
                  Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MakedReviewsPage(),
          ),
        );
                },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("İncelemelerim",style: TextStyle(color: Colors.white,fontSize: 25)),
                          Row(
                            children: [
                                                          Text(reviewCountText,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                      
                              Icon(Icons.arrow_forward_ios,color: Colors.white,),
                            ],
                          )
                        ],
                      ),
                    ),
                    FutureBuilder(
                              future: yorum.where("uye_id", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get(),
                              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                            return Text('Hata: ${snapshot.error}');
                                } else {
                            return Column(
                              children:  snapshot.data!.docs.isEmpty
      ? [
          Text(
            'Henüz hiç inceleme yapmadınız.',
            style: TextStyle(color: Colors.white,fontSize: 20),
          ),
        ]
      :snapshot.data!.docs.sublist(0,min(4,snapshot.data!.docs.length)).map((doc) {
                                return FutureBuilder<DocumentSnapshot<Object?>>(
                                  future: kitaplar.doc(doc['kitap_id']).get(),
                                  builder: (context, AsyncSnapshot<DocumentSnapshot> kitapSnapshot) {
                    if (kitapSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (kitapSnapshot.hasError) {
                      return Text('Hata: ${kitapSnapshot.error}');
                    } else {
                      final kitapAdi = kitapSnapshot.data!['kitap_ad'];
                      final yorum = doc['yorum'];


                      return Container(
                        padding: EdgeInsets.only(top: 20,left:5,right: 5 ),
                        child: Row(
                          children: [
                            
                             GestureDetector(
                              onTap: (){
                                Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(bookData:kitapSnapshot.data! ),
          ),
        );
                              },
                               child: Container(
                                height: 100,
                                                     decoration: BoxDecoration(
                                                       borderRadius: BorderRadius.all(Radius.circular(25)),
                                                     ),
                                                     child: ClipRRect(
                                                       borderRadius: BorderRadius.circular(12),
                                                       child: Image(image: NetworkImage(kitapSnapshot.data!["resim"]),fit: BoxFit.fitHeight,),
                                                     ),
                                                   ),
                             ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowReview(reviewData: doc,),
          ),
        );
                                },
                                child: Container(
                                  padding: EdgeInsets.only(left:15,right: 5 ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                   SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.5,
                                
                                    child: Text(kitapAdi,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize:20 ),overflow: TextOverflow.ellipsis,maxLines: 1,)),
                                   SizedBox(
                                     width: MediaQuery.of(context).size.width * 0.6,
                                
                                    child: Text(yorum,style: TextStyle(color: Colors.white54,fontSize:16,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,maxLines: 2,)),
                                   Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.star,color: Colors.amber,),
                                      Text(doc["rate"],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)
                                      
                                    
                                      ),
                                      SizedBox(width: 15,),
                                      Icon(Icons.thumb_up_alt_outlined,color: Colors.white,),
                                      Text(doc["begen"],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                                      SizedBox(width: 5,),
                                      Icon(Icons.thumb_down_alt_outlined,color: Colors.white,),
                                      Text(doc["begenme"],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))
                                    ],
                                   )
                                    ],
                                  ),
                                ),
                              ),
                              
                            
                          ],
                        ),
                      );
                    }
                                  },
                                );
                              }).toList(),
                            );
                                }
                              },
                            ),
                  ],
                ),
              ),
              SizedBox(height: 30,),
             Container(
              margin: EdgeInsets.only(bottom: 30),
                        padding: EdgeInsets.only(
                            left: 10, right: 15, bottom: 30, top: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          color: Colors.black,
                        ),
          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

            children: [
               GestureDetector(
                onTap: (){
                  Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LikedReviewsPage(),
          ),
        );
                },
                 child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Etkileşim",style: TextStyle(color: Colors.white,fontSize: 25)),
                          Row(
                            children: [
                              Text(totalInteractionCountText,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                              Icon(Icons.arrow_forward_ios,color: Colors.white,),
                            ],
                          )
                        ],
                      ),
               ),
              FutureBuilder(
                future: begeni.where("uye_id", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> begeniSnapshot) {
                      if (begeniSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
                      } else if (begeniSnapshot.hasError) {
              return Text('Hata: ${begeniSnapshot.error}');
                      } else {
              return Column(
                children: begeniSnapshot.data!.docs.isEmpty
      ? [
          Text(
            'Henüz hiç etkileşimde bulunmadınız.',
            style: TextStyle(color: Colors.white,fontSize: 20),
          ),
        ]
      : begeniSnapshot.data!.docs.sublist(0,min(4,begeniSnapshot.data!.docs.length)).map((doc) {
                  String yorumId = doc['yorum_id'];
                  return FutureBuilder<DocumentSnapshot>(
                    future: yorum.doc(yorumId).get(),
                    builder: (context,  yorumSnapshot) {
                      if (yorumSnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (yorumSnapshot.hasError) {
                        return Text('Hata: ${yorumSnapshot.error}');
                      } else {
                        final yorumIcerik = yorumSnapshot.data!['yorum'];
                        final kitapId = yorumSnapshot.data!['kitap_id'];
                        final yorumYapanUid = yorumSnapshot.data!['uye_id'];
final begeni = (doc.data() as Map<String, dynamic>)["begeni"];
                        return FutureBuilder<DocumentSnapshot>(
                          future: kitaplar.doc(kitapId).get(),
                          builder: (context, AsyncSnapshot<DocumentSnapshot> kitapSnapshot) {
                            if (kitapSnapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (kitapSnapshot.hasError) {
                              return Text('Hata: ${kitapSnapshot.error}');
                            } else {
                              final kitapAdi = kitapSnapshot.data!['kitap_ad'];
                              
                                return FutureBuilder<DocumentSnapshot>(
                        future: users.doc(yorumYapanUid).get(),
                        builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (userSnapshot.hasError) {
                            return Text('Hata: ${userSnapshot.error}');
                          }else {
                             final yorumYapanIsim = userSnapshot.data!['isim']+" "+userSnapshot.data!['soyisim'];

                         
                          return Container(
                                  padding: EdgeInsets.only(top: 20,left: 5,right: 5),
                                  child: Row(
                                    children: [
                                      
                                    GestureDetector(
                                      onTap: (){
Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(bookData:kitapSnapshot.data! ),
          ),
        );

                                      },
                                      child: Container(
                                                                      height: 100,
                                                       decoration: BoxDecoration(
                                                         borderRadius: BorderRadius.all(Radius.circular(25)),
                                                       ),
                                                       child: ClipRRect(
                                                         borderRadius: BorderRadius.circular(12),
                                                         child: Image(image: NetworkImage(kitapSnapshot.data!["resim"]),fit: BoxFit.fitHeight,),
                                                       ),
                                                     ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowReview(reviewData: yorumSnapshot.data as DocumentSnapshot<Object?>,),
          ),
        );
                                      },
                                      child: Container(
                                  padding: EdgeInsets.only(left:15,right: 5 ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                   SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.5,
                                
                                    child: Text(kitapAdi,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize:20 ),overflow: TextOverflow.ellipsis,maxLines: 1,)),
                                   SizedBox(
                                     width: MediaQuery.of(context).size.width * 0.6,
                                
                                    child: Text(yorumIcerik,style: TextStyle(color: Colors.white54,fontSize:16,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,maxLines: 2,)),
                                   SizedBox(
                                     width: MediaQuery.of(context).size.width * 0.6,
                                
                                    child: Text(yorumYapanIsim,style: TextStyle(color: Colors.white70,fontSize:16,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,maxLines: 2,)),
                                   
                                   
                                   Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.star,color: Colors.amber,),
                                      Text(yorumSnapshot.data!["rate"],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)
                                      
                                    
                                      ),
                                      SizedBox(width: 15,),
                                      Icon(
  begeni == "1" ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
  color: Colors.white,
),
                                      Text(yorumSnapshot.data!["begen"],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                                      SizedBox(width: 5,),
                                      Icon(
  begeni == "1" ? Icons.thumb_down_alt_outlined : Icons.thumb_up,
  color: Colors.white,
),
                                      Text(yorumSnapshot.data!["begenme"],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))
                                    ],
                                   )
                                    ],
                                  ),
                                ),
                                    )
                                    ],
                                  ),
                                );
                              }
                                }
                          );
                                
                                
                                
                                
                                
                                
                                
                            }
                          },
                        );
                      }
                    },
                  );
                }).toList(),
              );
                      }
                },
              ),
            ],
          ),
        )
            ],
          ),
        ),
      ),
    );
  }
}
