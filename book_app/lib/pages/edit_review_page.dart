// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class EditReviewPage extends StatefulWidget {
  final String bookId;
  final String userId;

  const EditReviewPage({
    super.key,
    required this.bookId,
    required this.userId,
  });

  @override
  _EditReviewPageState createState() => _EditReviewPageState();
}

class _EditReviewPageState extends State<EditReviewPage> {
  late QuerySnapshot reviewSnapshot;
  late TextEditingController _commentController;
  double _rating = 0.0;
  int hasReviewed = 0;

  Future<void> _fetchReviewData() async {
    try {
      reviewSnapshot = await FirebaseFirestore.instance
          .collection('Yorum')
          .where('kitap_id', isEqualTo: widget.bookId)
          .where('uye_id', isEqualTo: widget.userId)
          .get();

      if (reviewSnapshot.docs.isNotEmpty) {
        final reviewData = reviewSnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _commentController = TextEditingController(text: reviewData['yorum']);
          _rating = double.parse(reviewData['rate']);
          hasReviewed = 1;
        });
      } else {
        print('Kullanıcının bu kitap için bir incelemesi bulunamadı');
      }
    } catch (e) {
      print('İnceleme verileri alınırken bir hata oluştu: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _fetchReviewData();
  }

  void _updateReview() async {
    try {
      await FirebaseFirestore.instance.collection('Yorum').doc(reviewSnapshot.docs.first.id).update({
        'rate': _rating.toString(),
        'yorum': _commentController.text,
      });

      setState(() {
        hasReviewed = 1;
      });

      Navigator.pop(context);
    } catch (e) {
      print('İnceleme güncellenirken bir hata oluştu: $e');
    }
  }

  void _deleteReview() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Emin misiniz?"),
          content: Text("Yorumu silmek için 'Evet'e basınız. "),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Hayır"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('Yorum')
                      .doc(reviewSnapshot.docs.first.id)
                      .delete();
                      
                    QuerySnapshot likesSnapshot =  await FirebaseFirestore.instance
                      .collection('Begeni')
                      .where("yorum_id",isEqualTo: reviewSnapshot.docs.first.id).get();
                      
                      for (QueryDocumentSnapshot doc in likesSnapshot.docs) {
                  await doc.reference.delete();
                }

                  Navigator.pop(context, 0);
                  Navigator.pop(context,0);
                } catch (e) {
                  print('İnceleme silinirken bir hata oluştu: $e');
                }
              },
              child: Text("Evet"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İncelemeyi Düzenle'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteReview,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                  future: FirebaseFirestore.instance.collection('Kitaplar').doc(widget.bookId).get(),
                  builder: (context, snapshot) {
                     if (snapshot.hasError) {
                      return Text('Hata: ${snapshot.error}');
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
                                SizedBox(width: 200, child: Text(bookName!,overflow: TextOverflow.ellipsis,maxLines: 3,style: TextStyle(fontSize: 18),))
                              ],
                            ),
                          ),
                          Text(
                            'Yorumunuzu düzenleyin:',
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
                            'Puanınızı güncelleyin:',
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
                              
                              _updateReview();
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
                              'Güncelle',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
