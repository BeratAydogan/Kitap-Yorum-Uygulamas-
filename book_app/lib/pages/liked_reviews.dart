import 'package:book_app/pages/detail_page.dart';
import 'package:book_app/pages/show_review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LikedReviewsPage extends StatefulWidget {
  const LikedReviewsPage({super.key});

  @override
  State<LikedReviewsPage> createState() => _LikedReviewsPageState();
}

class _LikedReviewsPageState extends State<LikedReviewsPage> {
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
    return -1;
  }
}



@override
  void initState() {
    super.initState();
        _getUserTotalInteractionCountAndSetState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Etkileşimli İncelemeler - $totalInteractionCountText"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(bottom: 30),
          padding:
              const EdgeInsets.only(left: 10, right: 15, bottom: 30, top: 15),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: begeni
                    .where("uye_id",
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> begeniSnapshot) {
                  if (begeniSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (begeniSnapshot.hasError) {
                    return Text('Hata: ${begeniSnapshot.error}');
                  } else {
                    return Column(
                      children: begeniSnapshot.data!.docs.isEmpty
                          ? [
                              const Text(
                                'Henüz hiç etkileşimde bulunmadınız.',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            ]
                          : begeniSnapshot.data!.docs.map((doc) {
                              String yorumId = doc['yorum_id'];
                              return FutureBuilder<DocumentSnapshot>(
                                future: yorum.doc(yorumId).get(),
                                builder: (context, yorumSnapshot) {
                                  if (yorumSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (yorumSnapshot.hasError) {
                                    return Text('Hata: ${yorumSnapshot.error}');
                                  } else {
                                    final yorumIcerik =
                                        yorumSnapshot.data!['yorum'];
                                    final kitapId =
                                        yorumSnapshot.data!['kitap_id'];
                                    final yorumYapanUid = yorumSnapshot.data![
                                        'uye_id'];
                                    final begeni = (doc.data()
                                        as Map<String, dynamic>)["begeni"];
                                    return FutureBuilder<DocumentSnapshot>(
                                      future: kitaplar.doc(kitapId).get(),
                                      builder: (context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              kitapSnapshot) {
                                        if (kitapSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (kitapSnapshot.hasError) {
                                          return Text(
                                              'Hata: ${kitapSnapshot.error}');
                                        } else {
                                          final kitapAdi =
                                              kitapSnapshot.data!['kitap_ad'];
        
                                          return FutureBuilder<DocumentSnapshot>(
                                              future:
                                                  users.doc(yorumYapanUid).get(),
                                              builder: (context,
                                                  AsyncSnapshot<DocumentSnapshot>
                                                      userSnapshot) {
                                                if (userSnapshot
                                                        .connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const CircularProgressIndicator();
                                                } else if (userSnapshot
                                                    .hasError) {
                                                  return Text(
                                                      'Hata: ${userSnapshot.error}');
                                                } else {
                                                  final yorumYapanIsim =
                                                      userSnapshot.data!['isim'] +
                                                          " " +
                                                          userSnapshot
                                                              .data!['soyisim'];
        
                                                  return Container(
                                                   margin: const EdgeInsets.only(bottom: 30),
          padding:
              const EdgeInsets.only(bottom: 15, top: 15,left: 10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color: Colors.black
          ),
                                                    
                                                            
                                                    child: Expanded(
                                                      child: Row(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      DetailPage(
                                                                          bookData:
                                                                              kitapSnapshot
                                                                                  .data!),
                                                                ),
                                                              );
                                                            },
                                                            child: Container(
                                                              height: 100,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .all(Radius
                                                                            .circular(
                                                                                25)),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                child: Image(
                                                                  image: NetworkImage(
                                                                      kitapSnapshot
                                                                              .data![
                                                                          "resim"]),
                                                                  fit: BoxFit
                                                                      .fitHeight,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ShowReview(
                                                                    reviewData: yorumSnapshot
                                                                            .data
                                                                        as DocumentSnapshot<
                                                                            Object?>,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 15,
                                                                      ),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                      width: MediaQuery.of(
                                                                                  context)
                                                                              .size
                                                                              .width *
                                                                          0.6,
                                                              
                                                                      child: Text(
                                                                        kitapAdi,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                            fontSize:
                                                                                20),
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        maxLines: 1,
                                                                      )),
                                                                  SizedBox(
                                                                      width: MediaQuery.of(
                                                                                  context)
                                                                              .size
                                                                              .width *
                                                                          0.7,
                                                              
                                                                      child: Text(
                                                                        yorumIcerik,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .white54,
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        maxLines:
                                                                            1,
                                                                      )),
                                                                  SizedBox(
                                                                      width: MediaQuery.of(
                                                                                  context)
                                                                              .size
                                                                              .width *
                                                                          0.6,
                                                              
                                                                      child: Text(
                                                                        yorumYapanIsim,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .white70,
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        maxLines: 2,
                                                                      )),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      const Icon(
                                                                        Icons.star,
                                                                        color: Colors
                                                                            .amber,
                                                                      ),
                                                                      Text(
                                                                          yorumSnapshot
                                                                                  .data![
                                                                              "rate"],
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .white,
                                                                              fontWeight:
                                                                                  FontWeight.bold)),
                                                                      const SizedBox(
                                                                        width: 15,
                                                                      ),
                                                                      Icon(
                                                                        begeni ==
                                                                                "1"
                                                                            ? Icons
                                                                                .thumb_up
                                                                            : Icons
                                                                                .thumb_up_alt_outlined,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      Text(
                                                                          yorumSnapshot
                                                                                  .data![
                                                                              "begen"],
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .white,
                                                                              fontWeight:
                                                                                  FontWeight.bold)),
                                                                      const SizedBox(
                                                                        width: 5,
                                                                      ),
                                                                      Icon(
                                                                        begeni ==
                                                                                "1"
                                                                            ? Icons
                                                                                .thumb_down_alt_outlined
                                                                            : Icons
                                                                                .thumb_up,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      Text(
                                                                          yorumSnapshot
                                                                                  .data![
                                                                              "begenme"],
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .white,
                                                                              fontWeight:
                                                                                  FontWeight.bold))
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              });
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
        ),
      ),
    );
  }
}
