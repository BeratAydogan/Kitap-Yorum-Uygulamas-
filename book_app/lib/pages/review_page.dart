// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewPage extends StatefulWidget {
  final String bookId;
  const ReviewPage({super.key, required this.bookId});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0.0;

  void addReviewToFirestore(String bookId, String rate, String uyeId,
      String yapilmaT, String yorum) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('Yorum')
          .where('kitap_id', isEqualTo: bookId)
          .get();

      List<DocumentSnapshot> documents = querySnapshot.docs;

      int totalReviews = documents.length;

      double currentRating = 0.0;
      for (DocumentSnapshot document in documents) {
        currentRating += double.parse(document['rate']);
      }
      double newRating =
          (currentRating + double.parse(rate)) / (totalReviews + 1);
      String newRatingString = newRating.toString();
      await firestore.collection('Kitaplar').doc(bookId).update({
        'puan': newRatingString,
      });
      await firestore.collection('Yorum').add({
        'kitap_id': bookId,
        'rate': rate,
        'uye_id': uyeId,
        'yapilma_t': yapilmaT,
        'yorum': yorum,
        'begen':"0",
        'begenme':"0",
    });
 setState(() {});
      print('Yorum başarıyla eklendi!');
    } catch (e) {
      print('Yorum eklenirken bir hata oluştu: $e');
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yorum Yap'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('Kitaplar')
                  .doc(widget.bookId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Hata: ${snapshot.error}');
                } else if (snapshot.data == null) {
                  return Text('Veri bulunamadı.');
                } else {
                  Map<String, dynamic>? bookData = snapshot.data?.data();
                  String? bookName = bookData?['kitap_ad'];
                  String? bookImageUrl = bookData?['resim'];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image(image: NetworkImage(bookImageUrl!)),
                            SizedBox(
                              width: 200,
                              child: Text(
                                bookName!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          ],
                        ),
                      ),
                      Text(
                        'Yorumunuzu yazın:',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Yorumunuzu buraya yazın...',
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Puanınızı verin:',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 30,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return ElevatedButton(
                            onPressed: () async {
                              String comment = _commentController.text.trim();
                              if (comment.isEmpty) {
                                // Yorum alanı boşsa uyarı göster
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Hata!'),
                                      content: Text('Lütfen bir yorum girin.'),
                                      shape: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    );
                                  },
                                );
                                return;
                              }
                              if (_rating == 0.0) {
                                // Puan verilmemişse uyarı göster
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Hata!'),
                                      content: Text('Lütfen bir puan verin.'),
                                      shape: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    );
                                  },
                                );
                                return;
                              }
                              addReviewToFirestore(
                                widget.bookId,
                                _rating.toString(),
                                FirebaseAuth.instance.currentUser!.uid.toString(),
                                DateTime.now().toString(),
                                comment,
                              );
                              Navigator.pop(context, 1);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.amber.shade800,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              minimumSize: Size(constraints.maxWidth, 50),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              textStyle: TextStyle(fontSize: 14),
                            ),
                            child: Text(
                              'Gönder',
                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}