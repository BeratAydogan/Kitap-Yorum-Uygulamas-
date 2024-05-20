// ignore_for_file: avoid_print

import 'package:book_app/pages/detail_page.dart';
import 'package:book_app/pages/show_review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MakedReviewsPage extends StatefulWidget {
  const MakedReviewsPage({super.key});

  @override
  State<MakedReviewsPage> createState() => _MakedReviewsPageState();
}

class _MakedReviewsPageState extends State<MakedReviewsPage> {
late String reviewCountText = '0';

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
     _getUserReviewCountAndSetState();
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
      appBar: AppBar(
        title: Text("Yapılan İncelemeler - $reviewCountText"),
      ),
      body: SingleChildScrollView(
        child: Container(
                  margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.only(
                              left: 10, right: 15, bottom: 30, top: 15),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            
                          ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      FutureBuilder(
                                future: yorum.where("uye_id", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get(),
                                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                              return Text('Hata: ${snapshot.error}');
                                  } else {
                              return Column(
                                children:  snapshot.data!.docs.isEmpty
        ? [
            const Text(
              'Henüz hiç inceleme yapmadınız.',
              style: TextStyle(color: Colors.white),
            ),
          ]
        :snapshot.data!.docs.map((doc) {
                                  return FutureBuilder<DocumentSnapshot<Object?>>(
                                    future: kitaplar.doc(doc['kitap_id']).get(),
                                    builder: (context, AsyncSnapshot<DocumentSnapshot> kitapSnapshot) {
                      if (kitapSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (kitapSnapshot.hasError) {
                        return Text('Hata: ${kitapSnapshot.error}');
                      } else {
                        final kitapAdi = kitapSnapshot.data!['kitap_ad'];
                        final yorum = doc['yorum'];
        
        
                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.only(
                              left: 10, bottom: 15, top: 15),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            color: Colors.black
                          ),
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
                                                       decoration: const BoxDecoration(
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
                                    padding: const EdgeInsets.only(left:15,right: 5 ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                     SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.5,
                                  
                                      child: Text(kitapAdi,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize:20 ),overflow: TextOverflow.ellipsis,maxLines: 1,)),
                                     SizedBox(
                                       width: MediaQuery.of(context).size.width * 0.6,
                                  
                                      child: Text(yorum,style: const TextStyle(color: Colors.white54,fontSize:16,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,maxLines: 2,)),
                                     Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(Icons.star,color: Colors.amber,),
                                        Text(doc["rate"],style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold)
                                        
                                      
                                        ),
                                        const SizedBox(width: 15,),
                                        const Icon(Icons.thumb_up_alt_outlined,color: Colors.white,),
                                        Text(doc["begen"],style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 5,),
                                        const Icon(Icons.thumb_down_alt_outlined,color: Colors.white,),
                                        Text(doc["begenme"],style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold))
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
      ),
    );
  }
}